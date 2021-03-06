package Dancer2::Plugin::API::Resource;

use strict;
use warnings;

use Moo::Role;

#requires 'validate';
requires 'process';

# response envelope
#around process => sub {
#    my ($orig, $self) = (shift, shift);

    #   $self->execute_hook('plugin.api.resource.process.before');
#    my $result = $self->$orig(@_);
    #$result = $self->execute_hook('plugin.api.resource.process.after', $result);

#    return $result;
#};

has meta => (
    is      => 'ro',
#    isa     => HashRef,
    lazy    => 1,
    builder => '_meta',
);

requires '_meta';

1;
