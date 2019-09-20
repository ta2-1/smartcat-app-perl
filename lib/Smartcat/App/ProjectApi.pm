use strict;
use warnings;

package Smartcat::App::ProjectApi;

use Smartcat::Client::ProjectApi;
use Smartcat::Client::Object::CreateDocumentPropertyModel;
use Smartcat::Client::Object::ProjectChangesModel;
use Smartcat::App::Utils;

use Carp;
$Carp::Internal{ ('Smartcat::Client::ProjectApi') }++;
$Carp::Internal{ (__PACKAGE__) }++;

use Log::Any qw($log);

sub new {
    my ( $class, $api, $rundata ) = @_;

    my $self = bless(
        {
            api     => Smartcat::Client::ProjectApi->new($api),
            rundata => $rundata
        },
        $class
    );

    return $self;
}

sub get_project {
    my $self = shift @_;

    $log->info("Getting project '$self->{rundata}->{project_id}'...");
    my $project = eval {
        $self->{api}
          ->project_get( project_id => $self->{rundata}->{project_id} );
    };
    carp $log->error(
        sprintf(
            "Failed to get project '%s'.\nError:\n%s",
            $self->{rundata}->{project_id},
            format_error_message($@)
        )
    ) unless $project;

    return $project;
}

sub update_project_external_tag {
    my ($self, $name, $external_tag) = @_;

    my %args = (name => $name);
    $args{externalTag} = $external_tag if defined $external_tag;

    my $project =
      Smartcat::Client::Object::ProjectChangesModel->new(%args);

    %args = (
        project_id => $self->{rundata}->{project_id},
        model => $project);

    $log->info("Updating project '$self->{rundata}->{project_id}' with '$external_tag' external tag...");
    eval {
        $self->{api}->project_update_project( %args );
    };

    carp $log->error(
        sprintf(
            "Failed to update project '%s' with external_tag '%s'.\nError:\n%s",
            $self->{rundata}->{project_id},
            $external_tag,
            format_error_message($@)
        )
    ) if $@;

    return;
}

sub get_all_projects {
    my $self = shift @_;

    $log->info("Getting all projects...");
    my $projects = eval { $self->{api}->project_get_all; };
    carp $log->error(
        sprintf( "Failed to get all projects.\nError:\n%s",
            format_error_message($@) )
    ) unless $projects;

    return $projects;
}

sub upload_file {
    my ( $self, $path, $filename, $target_languages ) = @_;

    my %args;
    $args{targetLanguages} = $target_languages
      if defined $target_languages && @$target_languages > 0;

    my $document =
      Smartcat::Client::Object::CreateDocumentPropertyModel->new(%args);

    $log->info("Uploading file '$path'...");
    %args = (
        project_id     => $self->{rundata}->{project_id},
        document_model => $document,
        file           => {
            path     => $path,
            filename => $filename
        }
    );
    $args{disassemble_algorithm_name} =
      $self->{rundata}->{disassemble_algorithm_name}
      if defined $self->{rundata}->{disassemble_algorithm_name};

    my $documents = eval { $self->{api}->project_add_document(%args) };
    unless ($documents) {
        carp $log->error(
            sprintf(
                "Failed to upload file '%s'.\nError:\n%s",
                $path, format_error_message($@)
            )
        );
        exit -1;
    }

    return $documents;
}

1;
