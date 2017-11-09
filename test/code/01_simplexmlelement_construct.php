<?php

$xmlstr = file_get_contents(__DIR__ . "/../films.xml");

$sxe = new SimpleXMLElement($xmlstr);
echo $sxe->film[0]["title"];
