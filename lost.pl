#! /usr/bin/perl
#
# Author: Phil Eckert
# Date: 03/14/2014
#
# A script to look for lost jobs.
# Jobs that are still listed as running
# in the slurmdbd, but no longer present
# in slurm.
#
use strict;

#
# set the time to right now.
#
my $date = `date +%H:%M`;
chomp $date;

#
# format for sacct output.
#
my $format = "-o 'JobID,User,JobName,Account,State,Cluster,NodeList,NNodes,Partition,Elapsed'";

#
# Get all the clusters we know about.
#
my @clusters = `sacctmgr show clusters -n format=cluster`;


#
# Loop through the clusters getting and comparing data.
#
foreach my $clust (@clusters) {
	chomp $clust;
	$clust =~ s/ //g;

	printf("\nCLUSTER:$clust\n\n");

#
#	I tried to use the "-s R" to capture only running jobs, but
#	the output has more than just running jobs, so I just 
#	grep for RUNNING instead.
#
	my @sjobs = `sacct -a -M $clust -S $date  $format | grep RUNNING`;
	my @jobs = `squeue -M $clust -o %i -h`;

#
#	Compare running jobs in slurm with what the slurmdbd lists as running.
#
	foreach my $j1 (@sjobs) {
		chomp $j1;
		my ($jobid) = ($j1 =~ m/(\S+) /);

#
#		Ignore the steps.
#
		next if ($jobid =~ /\./);

		my $found = 0;
		foreach my $j2 (@jobs) {
			chomp $j2;
			$j2 =~ s/ //g;
			if ($jobid eq $j2) {
				$found++;
				last;
			}
		}

#
#		Didn't find the job.
#
		if (!$found) {
			printf("cant find job $j1\n");
		}
	}
}

