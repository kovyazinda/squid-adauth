#!/usr/bin/perl

#Perl authentication helper for LDAP

# reads values from /etc/adauth.conf

use Net::LDAP;
use Net::LDAP::Util qw(ldap_error_text);
use Authen::Simple::LDAP;
use URI::Escape;

$configfile = "/etc/adauth.conf";

open FH, $configfile or die "Cannot open configureation file : $configfile\n";
readconfig();

#reading config file
sub readconfig
        {
        @filelines=<FH>;
        foreach (@filelines)
                {
                if ($_ !~ /^#/)
                        {
#			print $_;
			if ($_ =~ /^domain/i)
			    {
			    chomp;
			    $domain = $_;
			    $domain =~ s/^domain=//i;
			    }
			if ($_ =~ /^binddn/i)
			    {
			    chomp;
			    $binddn = $_;
			    $binddn =~ s/^binddn=//i;
			    }
			if ($_ =~ /^bindpw/i)
			    {
			    chomp;
			    $bindpw = $_;
			    $bindpw =~ s/^bindpw=//i;
			    }
			if ($_ =~ /^basedn/i)
			    {
			    chomp;
			    $basedn = $_;
			    $basedn =~ s/^basedn=//i;
			    }
			if ($_ =~ /^groupname/i)
			    {
			    chomp;
			    $groupname = $_;
			    $groupname =~ s/^groupname=//i;
			    }
			    
                        }
                };
        }

#bind parameters


# debug 
#print $domain,"\n";
#print $binddn,"\n";
#print $bindpw,"\n";
#print $basedn,"\n";
#print $groupname,"\n";

close FH;

# do not buffer stdout
$|=1;

#$username = @ARGV[0];
#$password = @ARGV[1];


#authentication parameters - same for all AD installations
$authfilter = '(&(objectClass=organizationalPerson)(objectClass=user)(sAMAccountName=%s))';

#search parameters
my $attrs = "sn, cn, givenname";


while (<>)
    {
# getting username and password from stdin and 
# splitting them with space separator
    ($username,$password) = split;
    
    if ($username ne "" and $password ne "")
	{

# debug
#print "Old username: $username";

# Internel explorer -  transparent authentication
# stripping leading domain and backslash if credentials are passed in UNC form
	if ($username =~ /\\\\/)
	    {
	    $username =~ s/^.*\\\\//;

# debug
#	    print "New username: $username";
	    }	

	if ($username =~ /\\/)
	    {
	    $username =~ s/^.*\\//;

# debug
#	    print "New username: $username";
	    }	

#debug logging 
#$logfile = '>>/tmp/adauth.log';
#open FH2, $logfile;
#print FH2 "$username - $password \n";
#close FH2;


# stripping %5C (\) and leading domain if credentials are passed in UNC form

	if ($username =~ /\%5C/)
	    {
	    $username =~ s/^.*\%5C//;

# debug
#	    print "New username: $username";
	    }	

# stripping @ and trailing domain if credentials are passed in FQDN form


	if ($username =~ /\@/)
	    {
	    $username =~ s/\@.*//;

# debug
#	    print "New username: $username";
	    }	

	
	adauth($username,$password);
	}
    else
	{
	adauth("anonymous","noauth");
	}
    }

sub adauth($)
    {
    ($username,$password)=@_;
    
# Authentication handle
    my $ldap = Authen::Simple::LDAP->new(
        host    => $domain,
	binddn	=> $binddn,
        bindpw  => $bindpw,
        basedn  => $basedn,
        filter  => $authfilter
    );

# checking group membership

# used for search
my $filter_group = "cn=$groupname";
    
# Search handle
# Stage 1 - bind

    my $ad = Net::LDAP -> new ("$domain") or die "Cannot Connect to AD - $domain";
    $ad -> bind ($binddn, password=>$bindpw, version => 3) or die "Cannot bind to AD - incorrect user password";



# Stage 2 - search

#debug
#    print "search parameters: \n basedn = $searchdn \n filter = $filter_group \n attrs = $attrs \n ";

    my $search = $ad -> search
    (
    base => $basedn,
    filter => $filter_group,
    attrs => $attrs
    );

    die ldap_error_text($search -> code) if $search->code;

my $count = $search -> count;

# Reading results of query - from Net::LDAP::FAQ
for (my $index = 0 ; $index < $count; $index++)
    {
    my $entry = $search->entry($index);
# getting entry DN
    my $dn = $entry->dn;
        
# debug
#    print $dn."\n";

# nullifying control variable
$found = "0";

# getting entry list of attributes and values
    @attrs = $entry->attributes;
	foreach my $var (@attrs)
	    {
	    $attr = $entry->get_value ($var, asref => 1);
		if (defined($attr))
		    {
		        foreach my $value (@$attr)
		    	    {
# debug		    	    
#			    print "Attribute $var : $value\n";
			    if ($var eq "member" and $value =~ /$username/i)
				{
# debug				
#				 print $value;
		    
				$found = "1";
				
			        if ( $ldap->authenticate( $username, $password ) ) 
				    {
# successfull authentication
    				    print "OK\n";
    				    }
				    else
				    {
# unsuccessfull authentication
    				    print "ERR\n";
				    }

				}
			    
			    }
		    }
	    }
    if ($found ne "1")
    {
    print "ERR\n";
    }

    }

# disconnecting from AD
$ad->unbind;
    
    
    }

