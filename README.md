#adauth.pl - written by Denis Kovyazin (kovyazinda@gmail.com)

Introduction
This script allows to perform user/group authentication in Active Directory for Squid. The advantage above the ntlm_auth is that no winbind and samba installation is necessary.

Details
1. Description

This script allows to perform user/group authentication in Active Directory for Squid.

2. Installation

2.1a Debian Linux (tested on Ubuntu, Debian): Install package libauthen-simple-ldap-perl with all dependencies

2.1b Redhat Linux (tested on Redhat Enterpise Linux): Install packages with all dependencies (replace x86_64 to i686 on x86 system):

perl-Params-Validate.x86_64

perl-LDAP.noarch

Then launch CPAN:

sudo cpan

And in CPAN install module with all dependencies:

cpan>install Authen::Simple::LDAP

2.1c FreeBSD: Use cpan to install perl modules. I had problem installing Authen::Simple::LDAP with all dependencies due to obsolete version of Attribute::Handlers. Following sequence has worked for me:

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
Multiple groups of user can be specified, use comma (,) separator
groupname=Users.Proxy,Users.ProxyAdmins


4. Edit /etc/squid.conf:

4.1 Add or update authentication parameters

#AD authentication

auth_param basic program /usr/bin/adauth.pl

auth_param basic children 5

auth_param basic realm Squid proxy

auth_param basic credentialsttl 2 hours

auth_param basic casesensitive off

4.2 Create ACL for authentication

# authentication

acl password proxy_auth REQUIRED

4.3 Put this ACL to the bottom of your rules allowing access. Warning - remove all http_access rules which allow access based on MAC or IP which preceed authentication rule.

# authentication

http_access allow password

4.4 If you need to combined access based on password and source ip, modify http_access authentication rules to:

# authentication

http_access allow password mynet
