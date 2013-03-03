package Dancer2::Plugin::API;

use strict;
use warnings;

#use Dancer2 ':syntax';
use Dancer2::Plugin;
use Dancer2::Plugin::API::Handler;
use Dancer2::Plugin::API::Swagger;

register_hook 'envelope';

register swagger => \&Dancer2::Plugin::API::Swagger::register_swagger_routes;

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
    my $cache = setting('plugin.api.resources.cache'); 
    if(!defined $cache){
        $cache = {};
        setting('plugin.api.resources.cache' => $cache);
    }
    return $cache;
};

register resource => sub {
    my ($dsl, $name) = @_;

    my $resource = resources_cache()->{$name};
    if (!defined $resource){
        # TODO verify it's a Moo role resource
        debug sprintf 'creating: %s', $name;
        $resource = $name->new(); 
        resources_cache()->{$name} = $resource;
    }

    return $resource;
};

register_plugin for_versions => [2];
1;
