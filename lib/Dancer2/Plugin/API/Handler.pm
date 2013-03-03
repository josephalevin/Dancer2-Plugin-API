package Dancer2::Plugin::API::Handler;

use strict;
use warnings;

#use Dancer2 ':syntax';
#use Dancer2::Plugin;

use Module::Pluggable::Object;
use Data::Dumper;

my $_meta = {};

#register _register_resources => sub {
#    my ($dsl, %args) = plugin_args(@_);
#};
#

sub register_resources {
    my ($dsl, %args) = @_;

    # TODO: add a Moo role check here to make sure the plugins are resources
    my %options = (
        search_path => $args{search_path},
        require     => 1,
#        instantiate => 'new',
    );

    my $finder = Module::Pluggable::Object->new(%options);

    $dsl->debug ('Beginning service resource initialization.');

    for my $resource ($finder->plugins) {
        my $meta = $resource->_meta();

        my $name = $meta->{name};
        $dsl->debug ("Registering '$name' resource.");
        
        my $verb = lc $meta->{verb};
        my $path = $meta->{path};

        # keep track of all the operations under a resource path
        my $resource_name = $1 if $path =~ qr(^\/?(\w+)\/?);
        $_meta->{$resource_name}->{$path} = [] unless $_meta->{$resource_name}->{$path};
        push @{$_meta->{$resource_name}->{$path}}, $meta;

        # convert the path to the dancer route format, changes {param} into :param?
        $path =~ s/({([\w_\-\.]+)})/:$2?/g;

        my $prefix = $dsl->app->prefix;
        $dsl->debug (sprintf('%s %s%s => %s', uc $verb, $prefix, $path, $resource )); 

        # register the call for the verb and path pattern 
        my $handler = sub {
            my ($context) = @_;
            #my $resource_cache = $dsl->setting('plugin.api.resource.cache');
          
            # TODO: cache the resource instances 
            my $r = $resource->new();
             # validate the input
                          
             # before resource hook
             #$resource->before_process(@_);
# 
             # quit if there were any errors
#            f(@{errors()}){
#                $envelope->{errors} = errors;                
#                status (400);
#                return $envelope;
#            }

            # call the handler
            my ($status, $result) = $r->process($dsl, $context);
            $dsl->status ($status);

            # collect warnings and errors
                       
                            
            # output the result wrapped in an envelope
            my $envelope = $dsl->app->execute_hook('plugin.api.envelope', $dsl, $result) || $result;
            return $envelope;
        }; 
        
        $dsl->app->add_route(method => $verb,  regexp => $path, code => $handler);
        $dsl->app->add_route(method => 'head',  regexp => $path, code => $handler) if $verb =~ /get/i;
    }
           
    $dsl->debug ('Finished application resource initialization.');
}

1;

