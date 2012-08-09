NAME
    pdf-merge - Web interface for merging PDF documents.

SYNOPSIS
     % pdf-merge

    then point your browser to

    *   http://localhost:3001

DESCRIPTION
    This application provides a web interface for merging multiple PDF
    documents so they can be sent to a printer for physical copies.

    My apartment doesn't have room for a printer (not with all my junk which
    is apparently more important), so when I need to print something I use a
    virtual PDF printer (cups-pdf in Debian, other distributions and
    operating systems probably have similar packages) and take the PDFs to
    FedEx Office. Unfortunately the self service facility for printing
    multiuple PDFs has a sucky interface so it is better to go there with
    one big PDF rather than many little PDFs. The intent is to use the
    virtual PDF printer to print to ~/PDF, and then merge them with this web
    application into a single PDF which I save to the memory stick which I
    take to the FedEx Office.

    The application is implemeted with Mojolicious, plus a few other modules
    available on CPAN.

    By default, pdf-merge only listens to port 3001 (not to conflict with
    other Mojolicious applications) and binds only to 127.0.0.1. If you want
    to bind to something else start the application with the normal
    Mojolicous start up

     % pdf-merge daemon -l http://\*:3002
     [Wed Aug  8 22:22:23 2012] [info] Listening at "http://*:3002".
     Server available at http://127.0.0.1:3002.

SEE ALSO
    Mojolicious, Mojolicious::Plugin::TtRenderer,
    Mojolicious::Plugin::RenderFile

AUTHOR
    Graham Ollis <plicease@wdlabs.com>

COPYRIGHT
    Copyright 2012 Graham Ollis

LICENSE
    This is free software; you can redistribute it and/or modify it under
    the same terms as the Perl 5 programming language system itself.

