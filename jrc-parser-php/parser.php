#!/usr/bin/php
<?php

require "vendor/autoload.php";

use Symfony\Component\Console\Application;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

// use Sabre\XML;

define("CACHE_DIRECTORY", dirname(__FILE__) . "/cache");

$console = new Application();

$console
    ->register('fetch')
    ->setDefinition(array(
        new InputArgument('address', InputArgument::REQUIRED, 'Target web page'),
    ))
    ->setDescription('Fetches the web page at the given address and scrapes its puzzles')
    ->setCode(function (InputInterface $input, OutputInterface $output) {
        // Need cache dir
        if(!is_dir(CACHE_DIRECTORY) || !is_writable(CACHE_DIRECTORY)) {
            $output->writeln("fatal: Cache directory doesn't exist or isn't writeable at: "
                . CACHE_DIRECTORY);
            die();
        }
        // Lookup page in cache or download from address
        $address = $input->getArgument('address');
        $cacheDriver = new \Doctrine\Common\Cache\FilesystemCache(CACHE_DIRECTORY);
        if($html = $cacheDriver->fetch($address))
            $output->writeln("Found page by address in cache.");
        else {
            $output->writeln("Downloading page at $address ...");
            $html = file_get_contents($address);
            $cacheDriver->save($address, $html);
        }

        $allowedTags = '<table><tr><td><tbody><a><img><p><ul><li>';
        $html = strip_tags($html, $allowedTags);
        $html = "<puzzles>$html</puzzles>";
        // echo $html;
        // exit;

        // Parse the file
        libxml_use_internal_errors(true);
        try {
            $xml = new SimpleXMLElement($html, LIBXML_PARSEHUGE);
            var_dump($xml);
        }catch(Exception $e) {
            echo "Failed loading XML\n";
            foreach(libxml_get_errors() as $error) {
                echo "\t", $error->message;
            }
        }

        /*
        #2 Blew up my computer
    	$reader = new XML\Reader();
    	$reader->XML($html);
    	$tree = $reader->parse();
    	var_dump($tree);
        */

        /*
        #1 Couldn't cope with syntax
        libxml_use_internal_errors(true);
        $xml = new SimpleXMLElement($html);
        var_dump($xml);
        */
    })
;

$console->run();
