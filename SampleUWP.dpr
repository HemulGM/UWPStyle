program SampleUWP;

uses
  System.StartUpCopy,
  FMX.Forms,
  SampleUWP.Main in 'SampleUWP.Main.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
