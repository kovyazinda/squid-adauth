# Introduction #

This script allows to perform user/group authentication in Active Directory for Squid. The advantage above the ntlm\_auth is that no winbind and samba installation is necessary.

# Details #

1. Description

This script allows to perform user/group authentication in Active Directory for Squid.

2. Installation

2.1a **Debian Linux** (tested on Ubuntu, Debian): Install package _libauthen-simple-ldap-perl_ with all dependencies

2.1b **Redhat Linux** (tested on Redhat Enterpise Linux): Install packages with all dependencies (replace x86\_64 to i686 on x86 system):

_perl-Params-Validate.x86\_64_

_perl-LDAP.noarch_

Then  launch CPAN:

_sudo cpan_

And in CPAN install module with all dependencies:

_cpan>install Authen::Simple::LDAP_


2.1c **FreeBSD**: Use _cpan_ to install perl modules. I had problem installing _Authen::Simple::LDAP_ with all dependencies due to obsolete version of _Attribute::Handlers_. Following sequence has worked for me:

> _cpan>install_ _Attribute::Handlers_

> _cpan>install_ _Params::Validate_

> _cpan>install_ _Net::LDAP_

> _cpan>install_ _Authen::Simple_

> _cpan>install_ _Authen::Simple::LDAP_

2.2 Upload **adauth.pl** to **/usr/bin**, **adauth.conf** to **/etc**.

2.3 Create Active Directory account, which will be used to query AD

3. Configuration - Edit **/etc/adauth.conf**:

In "domain", put domain name which you want to query:

domain=**somedomain.com**

In binddn and bindpw, specify DN of and password of account create in p.2.3:

binddn=**CN=adbind,CN=Users,DC=somedomain,DC=com**

bindpw=**bindpassword**

In basedn specify container in which to start search (for optimization), if unsure, put DC=somedomain,DC=com here:

basedn=**CN=Users,DC=somedomain,DC=com**


AD Group of users, which is allowed to use squid proxy:

groupname=**Users.Proxy**

4. Edit **/etc/squid.conf**:

4.1 Add or update authentication parameters

_#AD authentication_

_auth\_param basic program /usr/bin/adauth.pl_

_auth\_param basic children 5_

_auth\_param basic realm Squid proxy_

_auth\_param basic credentialsttl 2 hours_

_auth\_param basic casesensitive off_


4.2 Create ACL for authentication

_# authentication_

_acl password proxy\_auth REQUIRED_

4.3 Put this ACL to the bottom of your rules allowing access. **Warning - remove all http\_access rules which allow access based on MAC or IP which preceed authentication rule.**


_# authentication_

_http\_access allow password_

4.4 **If you need to combined access based on password and source ip, modify http\_access authentication rules to:**

_# authentication_

_http\_access allow password mynet_