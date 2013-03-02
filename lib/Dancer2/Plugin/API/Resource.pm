package Dancer2::Plugin::API::Resource;

use strict;
use warnings;

use Moo::Role;
with 'Dancer2::Core::Role::Engine';

sub supported_hooks {
    qw(
      plugin.api.resource.validate.before
      plugin.api.resource.validate.after
      plugin.api.resource.process.before
      plugin.api.resource.process.after
    );
}

sub _build_type {'Resource'}

requires 'process';

# response envelope
around process => sub {
    my ($orig, $self) = (shift, shift);

    $self->execute_hook('plugin.api.resource.process.before');
    my $result = $self->$orig(@_);
    $result = $self->execute_hook('plugin.api.resource.process.after', $result);

    return $result;
};

has meta => (
    is      => 'ro',
#    isa     => HashRef,
    lazy    => 1,
    builder => 1,
);

requires '_build_meta';

1;
