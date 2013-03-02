package Dancer2::Plugin::API;

use strict;
use warnings;

use Dancer2::Plugin;
use Dancer2::Plugin::API::Handler;

register_hook 'envelope';

register register_resources => \&Dancer2::Plugin::API::Handler::register_resources;

register_plugin for_versions => [2];
1;
