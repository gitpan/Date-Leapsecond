use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Date::Leapsecond',
    'VERSION_FROM'	=> 'lib/Date/Leapsecond.pm',
    'PREREQ_PM'		=> { Time::Local => 0 }, 
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/Date/Leapsecond.pm', # retrieve abstract from module
       AUTHOR     => 'Flávio Soibelmann Glock <fglock@pucrs.br>') : ()),
);
