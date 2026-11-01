unit BlaiseTest;

{$mode objfpc}{$H+}

interface

uses
  JS, SysUtils;

function GetEcosystemTestVersion: string;

implementation

function GetEcosystemTestVersion: string;
begin
  Result := '1.1.0';
end;

end.
