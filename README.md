#adauth.pl - written by Denis Kovyazin (kovyazinda@gmail.com)

1. Description

This script allows to perform user/group authentication in Active Directory for Squid. 

2. Installation

2.1a Linux (tested on Ubuntu): Install package libauthen-simple-ldap-perl with all dependencies
2.1b FreeBSD: Use cpan to install perl modules. I had problem installing Authen::Simple::LDAP with all dependencies due
to obsolete version of Attribute::Handlers. Following sequence has worked for me:

	cpan>install Attribute::Handlers
	cpan>install Params::Validate
	cpan>install Net::LDAP
	cpan>install Authen::Simple
	cpan>install Authen::Simple::LDAP

2.2 Upload adauth.pl to /usr/bin, adauth.conf to /etc.
2.3 Create Active Directory account, which will be used to query AD 

3. Configuration - Edit /etc/adauth.conf:

In "domain", put domain name which you want to query:
domain=somedomain.com

In binddn and bindpw, specify DN of and password of account create in p.2.3:
binddn=CN=adbind,CN=Users,DC=somedomain,DC=com
bindpw=bindpassword

In basedn specify container in which to start search (for optimization), if unsure, put DC=somedomain,DC=com here:
basedn=CN=Users,DC=somedomain,DC=com

AD Group of users, which is allowed to use squid proxy:
groupname=Users.Proxy

Note for v.0.2:
Multiple groups of users can be specified, use comma (,) separator
groupname=Users.Proxy,Users.ProxyAdmins
