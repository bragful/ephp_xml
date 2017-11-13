<?php

$data = file_get_contents("test/films.xml");
var_dump(simplexml_load_string($data));

