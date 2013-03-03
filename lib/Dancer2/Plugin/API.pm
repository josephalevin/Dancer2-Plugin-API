package Dancer2::Plugin::API;

use strict;
use warnings;

#use Dancer2 ':syntax';
use Dancer2::Plugin;
use Dancer2::Plugin::API::Handler;

register_hook 'envelope';

register register_resources => \&Dancer2::Plugin::API::Handler::register_resources;

register resources_meta => sub {
   
    my $meta = setting('plugin.api.resources.meta'); 
    if(!defined $meta){
        $meta = {};
        setting('plugin.api.resources.meta' => $meta);
    }
    return $meta;
};

register resources_cache => sub {
   
    my $meta = setting('plugin.api.resources.meta'); 
    if(!defined $meta){
        $meta = {};
        setting('plugin.api.resources.meta' => $meta);
    }
    return $meta;
};

get '/test' => sub {
    my ($context) = @_;
    return resources_meta();
};

register_plugin for_versions => [2];
1;
