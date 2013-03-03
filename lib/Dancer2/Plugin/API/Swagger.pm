package Dancer2::Plugin::API::Swagger;

use strict;
use warnings;

#use Dancer ':syntax';
#use Dancer::Plugin;

use JSON;
sub register_swagger_routes {
    my ($dsl, %options) = @_;

    my $api_version = $options{api_version} || 0.0;
    my $api_prefix = $options{api_prefix} || $dsl->app->prefix();

    # make sure the swagger api is json
    $dsl->set (serializer => 'JSON');

    my $prefix = $dsl->app->prefix() . '/meta';

    # root meta built from the resources defined under Interview::Service::Resource
    $dsl->get( '/meta' => sub {
        my $result = {
            apiVersion      => $api_version + 0,
            swaggerVersion  => 1.1,
            basePath        => $dsl->request->uri_for($prefix)->as_string,
            apis            => [],
        };

        for my $resource (keys %{$dsl->resources_meta()}){
            push @{$result->{apis}}, {
                'path' => '/'. $resource,
                 description => 'Operations for ' . $resource,
            };
        }

        return $result;
    });

    $dsl->get ('/meta/:resource' => sub {
        my $result = {
            apiVersion => $api_version + 0,
            swaggerVersion => 1.1,
            basePath => $dsl->request->uri_for($api_prefix)->as_string,
            resourcePath => $dsl->param ('resource'),
            apis => [],
            models => []
        };

        my @paths = keys %{$dsl->resources_meta()->{$dsl->param ('resource')}};
        for my $path (sort {length($a) <=> length($b)} @paths){
            my $api = {
                path => $path,
                description => 'Operations for ' . $path,
                operations => [],
            };
            push @{$result->{apis}}, $api;

            # add each of the operations for the path
            my @ops = @{$dsl->resources_meta()->{$dsl->param ('resource')}->{$path}};

            for my $meta (@ops){
                my $op = {
                    httpMethod      => $meta->{verb},
                    nickname        => $meta->{name},
                    summary         => $meta->{summary},
                    notes           => $meta->{details},
                    parameters      => [],
                    errorResponses  =>[],
                };
                push @{$api->{operations}}, $op;

                # add input parameters
                for my $input_name (sort keys %{$meta->{input}}){
                    my $input = $meta->{input}->{$input_name};
                    push @{$op->{parameters}}, {
                        name        => $input_name,
                        description => $input->{description},
                        paramType   => $input->{source},
                        dataType    => $input->{type},
                        required    => ($input->{required} ? \1 : \0),
                    };
                }

                for my $output_code (sort keys %{$meta->{output}}){
                    my $output = $meta->{output}->{$output_code};
                    push @{$op->{errorResponses}}, {
                        code        => $output_code,
                        reason      => $output->{reason},
                    };
                }

            }

        }

        return $result;
    });

}

1;
