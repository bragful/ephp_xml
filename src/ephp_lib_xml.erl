-module(ephp_lib_xml).
-author('manuel@altenwald.com').
-compile([warnings_as_errors]).

-behaviour(ephp_func).

-export([
    init_func/0,
    init_config/0,
    init_const/0,

    get_classes/0,

    sxmlel_construct/4,
    sxmlel_get/4,

    simplexml_load_string/3
]).

-import(ephp_class, [class_attr/2, class_attr/3]).

-include_lib("ephp/include/ephp.hrl").

-spec init_func() -> ephp_func:php_function_results().

init_func() -> [
    {simplexml_load_string, [
        pack_args,
        {args, [string,
                {string, <<"SimpleXMLElement">>},
                {integer, 0},
                {string, <<>>},
                {boolean, false}]}
    ]}
].

-spec init_config() -> ephp_func:php_config_results().

init_config() -> [].


-spec init_const() -> ephp_func:php_const_results().

init_const() -> [].

-spec get_classes() -> [class()].

get_classes() ->
    Method = #class_method{code_type = builtin,
                           pack_args = true,
                           args = []},
    [#class{
        name = <<"SimpleXMLElement">>,
        methods = [
            Method#class_method{
                name = <<"__construct">>,
                args = [
                    #variable{name = <<"data">>},
                    #variable{name = <<"options">>,
                              default_value = 0},
                    #variable{name = <<"data_is_url">>,
                              default_value = false,
                              data_type = <<"Exception">>},
                    #variable{name = <<"ns">>,
                              default_value = <<>>},
                    #variable{name = <<"is_prefix">>,
                              default_value = false}
                ],
                builtin = {?MODULE, sxmlel_construct}
            },
            Method#class_method{
                name = <<"addAttribute">>,
                args = [
                    #variable{name = <<"name">>},
                    #variable{name = <<"value">>, default_value = <<>>},
                    #variable{name = <<"namespace">>, default_value = <<>>}
                ],
                builtin = {?MODULE, sxmlel_add_attribute}
            },
            Method#class_method{
                name = <<"addChild">>,
                args = [
                    #variable{name = <<"name">>},
                    #variable{name = <<"value">>, default_value = <<>>},
                    #variable{name = <<"namespace">>, default_value = <<>>}
                ],
                builtin = {?MODULE, sxmlel_add_child}
            },
            Method#class_method{
                name = <<"asXML">>,
                args = [
                    #variable{name = <<"filename">>, default_value = <<>>}
                ],
                builtin = {?MODULE, sxmlel_as_xml}
            },
            Method#class_method{
                name = <<"attributes">>,
                args = [
                    #variable{name = <<"ns">>, default_value = undefined},
                    #variable{name = <<"is_prefix">>, default_value = false}
                ],
                builtin = {?MODULE, sxmlel_attributes}
            },
            Method#class_method{
                name = <<"children">>,
                args = [
                    #variable{name = <<"ns">>, default_value = undefined},
                    #variable{name = <<"is_prefix">>, default_value = false}
                ],
                builtin = {?MODULE, sxmlel_children}
            },
            Method#class_method{
                name = <<"count">>,
                builtin = {?MODULE, sxmlel_count}
            },
            Method#class_method{
                name = <<"getDocNamespaces">>,
                args = [
                    #variable{name = <<"recursive">>, default_value = false},
                    #variable{name = <<"from_root">>, default_value = true}
                ],
                builtin = {?MODULE, sxmlel_get_doc_namespaces}
            },
            Method#class_method{
                name = <<"getName">>,
                builtin = {?MODULE, sxmlel_get_name}
            },
            Method#class_method{
                name = <<"getNamespaces">>,
                args = [
                    #variable{name = <<"recursive">>, default_value = false}
                ],
                builtin = {?MODULE, sxmlel_get_namespaces}
            },
            Method#class_method{
                name = <<"registerXPathNamespace">>,
                args = [
                    #variable{name = <<"recursive">>, default_value = false}
                ],
                builtin = {?MODULE, sxmlel_register_xpath_namespace}
            },
            Method#class_method{
                name = <<"__toString">>,
                builtin = {?MODULE, sxmlel_to_string}
            },
            Method#class_method{
                name = <<"xpath">>,
                args = [
                    #variable{name = <<"path">>}
                ],
                builtin = {?MODULE, sxmlel_xpath}
            },
            Method#class_method{
                name = <<"__get">>,
                args = [
                    #variable{name = <<"name">>}
                ],
                builtin = {?MODULE, sxmlel_get}
            }
        ]
    }].

simplexml_load_string(Context, Line, [Data, {_, ClassName}, Options,
                                      NS, IsPrefix]) ->
    Object = ephp_class:instance(undefined, Context, Context, ClassName, Line),
    IsURL = {undefined, false},
    sxmlel_construct(Context, Object, Line,
                     [Data, Options, IsURL, NS, IsPrefix]).

instance(Context, Line, ClassName, Data) ->
    ObjectId = ephp_class:instance(undefined, Context, Context, ClassName, Line),
    xml_to_object(Context, Line, ClassName, ObjectId, Data).

xml_to_object(Context, Line, ClassName, ObjectId, {_Tag, Attrs, Children}) ->
    ObjCtx = ephp_object:get_context(ObjectId),
    Class0 = ephp_object:get_class(ObjectId),
    Class1 = ephp_class:add_if_no_exists_attrib(Class0, <<"@attributes">>),
    Class2 = ephp_class:add_if_no_exists_attrib(Class1, <<"@cdata">>),
    AttrsArray = lists:foldl(fun({Name, Value}, Array) ->
        ephp_array:store(Name, Value, Array)
    end, ephp_array:new(), Attrs),
    ephp_context:set(ObjCtx, #variable{name = <<"@attributes">>}, AttrsArray),
    Tags = lists:usort([ Tag || {Tag, _, _} <- Children ]),
    Class3 = lists:foldl(fun(Tag, Class) ->
        ephp_context:set(ObjCtx, #variable{name = Tag}, ephp_array:new()),
        ephp_class:add_if_no_exists_attrib(Class, Tag)
    end, Class2, Tags),
    CData = lists:foldl(fun
        ({Tag, A, Content}, CData) ->
            Object = instance(Context, Line, ClassName, {Tag, A, Content}),
            ephp_context:set(ObjCtx, #variable{name = Tag, idx = [auto]}, Object),
            CData;
        (Binary, CData) when is_binary(Binary) ->
            ephp_array:store(auto, Binary, CData)
    end, ephp_array:new(), Children),
    ephp_context:set(ObjCtx, #variable{name = <<"@cdata">>}, CData),
    ephp_object:set_class(ObjectId, Class3),
    ObjectId.

sxmlel_construct(Context, ObjectId, Line,
                 [{_, Data}, _Options, {_, false}, _NS, _IsPrefix]) ->
    {Tag, Attrs, Children} = exomler:decode(Data),
    xml_to_object(Context, Line, <<"SimpleXMLElement">>, ObjectId,
                  {Tag, Attrs, Children}).

sxmlel_get(_Context, _Line, _ObjectId, [{_, _Name}]) ->
    io:format("name => ~p~n", [_Name]),
    ephp_array:new().
