#!/usr/bin/php
<?php

require "vendor/autoload.php";

use Symfony\Component\Console\Application;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

define("CACHE_DIRECTORY", dirname(__FILE__) . "/cache");

$console = new Application();

$console
    ->register('fetch')
    ->setDefinition(array(
        new InputArgument('address', InputArgument::REQUIRED, 'Target web page'),
    ))
    ->setDescription('Fetches the web page at the given address and scrapes its puzzles')
    ->setCode(function (InputInterface $input, OutputInterface $output) {
        if(!is_dir(CACHE_DIRECTORY) || !is_writable(CACHE_DIRECTORY)) {
            $output->writeln("fatal: Cache directory doesn't exist or isn't writeable at: "
                . CACHE_DIRECTORY);
            die();
        }

        $address = $input->getArgument('address');

        $cacheDriver = new \Doctrine\Common\Cache\FilesystemCache(CACHE_DIRECTORY);

        if($html = $cacheDriver->fetch($address))
            $output->writeln("Found page by address in cache.");
        else {
            $output->writeln("Downloading page at $address ...");
            $html = file_get_contents($address);
            $cacheDriver->save($address, $html);
        }

    })
;

$console->run();