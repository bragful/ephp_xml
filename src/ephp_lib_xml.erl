-module(ephp_lib_xml).
-author('manuel@altenwald.com').
-compile([warnings_as_errors]).

-behaviour(ephp_func).

-export([
    init_func/0,
    init_config/0,
    init_const/0,

    get_classes/0,

    sxmlel_construct/4
]).

-import(ephp_class, [class_attr/2, class_attr/3]).

-include_lib("ephp/include/ephp.hrl").

-spec init_func() -> ephp_func:php_function_results().

init_func() -> [
    {json_encode, [pack_args, {args, [mixed, {integer, 0}, {integer, 512}]}]}
    % {json_decode, [
    %     pack_args,
    %     {args, [string, {boolean, false}, {integer, 512}, {integer, 0}]}]}
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
            }
        ]
    }].


sxmlel_construct(_Context, _Line, _ObjectId,
                 [{_, _Data}, _Options, {_, false}, _NS, _IsPrefix]) ->
    ok.
