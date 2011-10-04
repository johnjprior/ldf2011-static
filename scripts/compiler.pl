# Basic conditions
use strict;
use warnings;
use File::Find;

# Filepaths
my $base_dir     = 'D:/Users/John/Documents/Website/leedsdigitalfestival_new';
my $content_dir  = join '/', $base_dir, 'content';
my $includes_dir = join '/', $content_dir, 'includes';
my $template_dir = join '/', $base_dir, 'templates';
my $html_dir     = join '/', $base_dir, 'html';
#my $domain       = 'www.emmawensley.co.uk/ldf/';
my $domain       = 'www.leedsdigitalfestival.com';


# Start
find(\&getFiles,$content_dir);

# Identifies appropriate files to process from those found
sub getFiles {
  if ($File::Find::name =~ /\.insdat$/  && $File::Find::name !~ /$includes_dir/) {
    print "\nProcessing $File::Find::name\n";
    processInsdat($File::Find::name);
  }
}

# Handles each found file
sub processInsdat {
  my $insdat = shift;
  my %data = parseInsdat($insdat);
  createHTML(\%data, $insdat);
}  

# Parses the data file
sub parseInsdat {
  my $insdat = shift;
  my %data;
  
  # Parse the data
  open (INSDAT, "<$insdat") || die "Couldn't open $insdat\n";
  
  my $multiline  = 0;
  my $terminator = '';
  my $array_pos = 0;
  my @include_files;
  
  LINE:while (my $line = <INSDAT>) {
    
	chomp $line;
	$line =~ s/\s$//;

	# Handle multiline fields part through
	if ($multiline) {
	  # Terminating multilines
	  if ($line eq $terminator) {
	    $multiline  = 0;
		$terminator = '';
		next LINE;
	  
	  # More data
	  } else {
		
		# Handle arrays
	    if ($terminator =~ /_(\d+)$/) {
		  my $field_name = $terminator;
	      $field_name =~ s/_(\d+)$//;
		  $array_pos = $1;
		
	  	  $data{$field_name}[$array_pos] .= "$line\n";
		
		# Handle scalars
		} else {
	      $data{$terminator} .= "$line\n";
		}
	  }
	
	# Identify multiline fields
	} elsif ($line =~ /(\w+):$/) {
	  $multiline  = 1;
	  $terminator = $1;
	
	# Handle single line fields
	} elsif ($line =~ /^(\w+):\s*(.*)$/) {
 	  my $field_name = $1;
	  my $data = $2;

	  # Handle arrays
	  if ($field_name =~ /_(\d+)$/) {
	    $field_name =~ s/_(\d+)$//;
		$array_pos = $1;
		
	    # Special case - include files
	    if ($field_name eq 'INCLUDE') {

		  $data =~ s/^\s*(.*?)\s*$/$1/;
		  $include_files[$array_pos] = join '/', $includes_dir, $data;
		
		# Standard data
		} else {
          $data{$field_name}[$array_pos] = $data;
		}
	
	  # Handle scalars
	  } else {
	    $data{$field_name} = $data;
	  }
	
	# Ignore everything else
	} else {
	  next LINE;
	}
  }
  
  close (INSDAT);
  
  # Get the include files
  my $i = 0;
  foreach my $file_path (@include_files) {
  	my %include_data = parseInsdat($file_path);
	
    foreach my $key (keys %include_data) {	
	  $data{$key}[$i] = $include_data{$key};
	}
	$i++;
  }
  
  return %data;
}

# Merges data with templates and saves out the HTML
sub createHTML {
  my $data   = shift;
  my $insdat = shift;
  
  # Define the target
  my $target_file = $insdat;
  
  if ($target_file =~ m^$content_dir(.*)/(.+?)\.insdat^) {
    $$data{URL} = "http://$domain/$1/$2.html";
	$target_file = "$html_dir/$1/$2.html";
  } else {
    die "Couldn't resolve destination for $target_file\n";
  }
  
  
  # Catch faulty template definitions
  if (!defined $$data{TEMPLATE_PATH}) {
    print "No template page for $insdat\n";
    return 0;
  }
  
  # Catch missing templates
  my $template = join '/', $template_dir, $$data{TEMPLATE_PATH};
  if (!-f $template) {
    print "Invalid TEMPLATE_PATH at $template for $insdat\n";
	return 0;
  }
  
  open (TPL, "<$template") || die "Couldn't open $template\n";
  open (HTML, ">$target_file") || die "Couldn't open $target_file\n";
  
  my $if_block    = 0; # Indicates an if state is active
  my $if_resolved = 0; # Indicates that the if purpose is complete
  my $if_active   = 0; # Indicates that the if condition has been met and currently applies
  my $if_equality;     # Indicates the if test type - equality (true) or definition (false)
  my $if_var;          # The variable to be tested
  my $if_test;         # The value to be equalled, if applicable
  
  
  LINE:while (my $line = <TPL>) {
  
    # Handle underway if blocks
	if ($if_block) {
	  # Check for the end of the if block
	  if ($line =~ m~<!-- insertifend -->~) {
		# Reset the if values ready for another block
		$if_block = 0;
		$if_active = 0;
		$if_resolved = 0;
		$if_equality = '';
		$if_var = '';
		$if_test = '';
		
	    next LINE;
  	  
	  # Check for the start of a new else segment
      } elsif ($line =~ m~<!-- insertelsif:\s*(.+)\s*-->~) {
		# Set the if block resolution if the previous block was already met
		if ($if_active) {
		print "a";
		  $if_active = 0;
		  $if_resolved = 1;
		  next LINE;
		}
		
		# Skip if the if block has already been resolved
		if ($if_resolved) {
		  next LINE;
		}
		 
        # Otherwise parse the condition		 
		($if_equality,$if_var,$if_test) = parseCondition($1);
		
		# Check the results of the test
		if (defined $$data{$if_var}) {;
		
		  # Successful definition test - we've already checked that the value is defined
		  if (!$if_equality) {
		    $if_active = 1;
			next LINE;		  
	      
		  # Successful equality test
		  } elsif ($if_equality && $$data{$if_var} eq $if_test) {
		    $if_active = 1;
			next LINE;
			
		  # Unsuccessful equality test
		  } elsif ($if_equality && $$data{$if_var} ne $if_test) {
		    next LINE;
		  } 
		  
		# Unsuccessful definition test
		} else {
		  next LINE;	
		}  
		
	  # Handle elses
      } elsif ($line =~ m~<!-- insertelse -->~) {
	  	
		# Set the if block resolution if the previous block was already met
		if ($if_active) {
		  $if_active = 0;
		  $if_resolved = 1;
		  next LINE;
		}
		
		# Skip if the if block has already been resolved
		if ($if_resolved) {
		  next LINE;
		}
		
	    $if_active = 1;
	  
	  # Bail out of the line if we're in an if block, the command state hasn't changed, and the condition isn't active
      } elsif (!$if_active) {
		
		next LINE;
      }
    } 
	
	# If we're here, we're either not in an if block or the if condition is active
    # Standard blocks
	if ($line =~ m~<!-- insert:\s*(\w+) -->~ && defined $$data{$1}) {
	  $line =~ s~<!-- insert:\s*(\w+) -->~$$data{$1}~;
	  print HTML $line;
	  
	# While loops
    } elsif ($line =~ m~<!-- insertwhile:\s*(\w+) -->~ && defined $$data{$1}[0]){
      my $key = $1;
	  
	  # Check for reverse ordering instructions
	  my $reverse_key = join '_', $key, 'REVERSE';
	  if (defined $$data{$reverse_key}) {
	    foreach my $datum  (reverse @{$$data{$key}}) {
	      print HTML $datum;
	    }
      } else {
	    foreach my $datum  (@{$$data{$key}}) {
	      print HTML $datum;
	    }
	  }

	# Start of a new if block
	} elsif ($line =~ m~<!-- insertif:\s*(.+)\s*-->~) {
	  if ($if_active) {
	    die "Error in template - nested if conditions are not supported\n";
	  }
	  
	  ($if_equality,$if_var,$if_test) = parseCondition($1);
	  $if_block = 1;	
		
	  # Check the results of the test
      if (defined $$data{$if_var}) {
		
		# Successful definition test - we've already checked that the value is defined
		if (!$if_equality) {
		  $if_active = 1;
		  next LINE;		  
	      
		# Successful equality test
		} elsif ($if_equality && $$data{$if_var} eq $if_test) {
		  $if_active = 1;
		  next LINE;
			
		# Unsuccessful equality test
		} elsif ($if_equality && $$data{$if_var} ne $if_test) {
		  next LINE;
		} 
		  
      # Unsuccessful definition test
	  } else {
	    next LINE;	
	  }  

	# Untransformed lines
	} else {
	  print HTML $line;
	}
  }
  
  close (TPL);
  close (HTML);
}

# Identify the condition in an if/else statement (equality or existence)
sub parseCondition {
  my $base_condition = shift;
  
  my ($if_equality,$if_var,$if_test);
  if ($base_condition =~ /(\w+)=(?:'|")(.*)(?:'|")/) {
    $if_equality = 1;
	$if_var = $1;
	$if_test = $2;
  } else {
    $if_equality = 0;
	$if_var = $base_condition;
	$if_test = '';
  }
  
  $if_var =~ s~\s~~g;
  return($if_equality,$if_var,$if_test);
}
