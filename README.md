vrfydmn
=======

Postfilx milter that rejects/fixes manipulated From:-header

Background
==========

1st scenario
------------

If you run web servers that host virtual domains, you often define PHP settings
that force a fixed enevelope-from address. Unfortunately many websites provide
contact formulas that take the sender e-mail address and copy that with the
PHP mail function to the From:-header.

If you run a mail server that checks SPF/DKIM and finally DMARC, you can get
into trouble, if the sender address belongs to a company that enforces a strict
DMARC policy. If a remote server (and that could also be yours!) receives such
a mail, the mail will be rejected, as your web server (or a relay server that
handles mail from the web server) fails the SPF, DKIM and DMARC test.

2nd scenarion
-------------

You provde mail services for customers that deliver their mail over submission.
If you have infected PCs where bots are going to send mails over users account,
they can fake the sender addresses.

vrfydmn
=======

This is a little milter that can i.e. run on a web server or a submission
server. In the first scenario described, you may like to run the milter with a
fix option. In this mode, it restores the From:-header with the envelope-from
address and inserts a ne Reply-To:-header with the former From:-header. This
will keep formulas working.

For the second scenario described, you may want to run the milter with a hard
reject, if the From:-address was faked.

At the current stage of this milter, it reads a simple map file (I am using
Postfix) containing all domains that the mail server is the final destionation.
Each time a mail is sent, the From:-header is decoded and the e-mail address is
split into local part and domain, where only the domain is taken for
comparison. In fact, all domains from the map file are compared to the domain,
which makes it easier with subdomains. If a domain was found in the mapped file,
mail can pass, else it will either be rejected or modified depended of the mode
the milters runs with.

As domain maps might be very large, the file is only read at startup and kept
in memory. You can send a -HUP signal to the milter to reload its maps and send
a -USR1 signal to dump all domains to syslog (or stdout, if running in debug
mode).

For both scenarios described above, you can find a samlpe picture of my current
mail system, which demonstrates the usecases

Usage
=====

Install libmilter and pymilter (the python package that wraps the C library).
After that you may create a user milter with group milter. I have provided two
init scripts. The vrfydmn.init is for systems that use sysvinit, the
vrfydmn.openrc is for Gentoo users (as I am). You may edit these and specify
options for the milter. Simply call the milter with --help to get an idea.

In Postfix, you may add the milter with:

	non_smtpd_milters=inet:[::1]:30072

for scenario one and

	smtpd_milters=inet:[::1]:30072

for the submission instance. Usually found in master.cf or maybe a second
instance. This depends on your system.

Features
========

I might integrate LDAP and SQL servers as well for lookups.

