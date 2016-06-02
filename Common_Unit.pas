unit Common_Unit;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SwConst_TLB,Math, ExtCtrls, SldWorks_TLB, ComObj,  ComCtrls,Menus;

function OpenSW: IModelDoc2;
function FindPlanes(ModelDoc:IModelDoc2): HResult;
function CloseSWShow:Hresult;

var
   xyPlane: IRefPlane;                    // Главная плоскость XY
   xzPlane: IRefPlane;                    // Главная плоскость XZ
   yzPlane: IRefPlane;                    // Главная плоскость YZ
   Razmer, privyaz: boolean;
   hr: Hresult;
   SW: ISldWorks;
   MD: IModelDoc2;
Type
  TmyRecord= Record
end;
  Trec= file of  TmyRecord;

implementation
   uses Unit1  ;
function FindPlanes(ModelDoc:IModelDoc2): HResult;
var

  f: IFeature;
  rp: IRefPlane;
  i: Byte;
  v: Variant;
  hr: HRESULT;
begin
  hr:=S_OK;
  f:= ModelDoc.IFirstFeature;
  if f=nil then
   hr:=S_FALSE;
  i:= 0;
  while (f <> nil) and (i <= 3) do
  begin
    if f.GetTypeName = 'RefPlane' then
    begin
      rp:= f.GetSpecificFeature as IRefPlane;
      v:= rp.GetRefPlaneParams;
      if (v[0] = 0) and (v[1] = 0) and (v[2] = 0) then
      begin
        Inc(i);
        if (v[6] = 0) and (v[7] = 0) and (v[8] <> 0) then
          xyPlane:= rp
        else if (v[6] <> 0) and (v[7] = 0) and (v[8] = 0) then
          yzPlane:= rp
        else if (v[6] = 0) and (v[7] <> 0) and (v[8] = 0) then
          xzPlane:= rp;
       end;
    end;
    f:= f.IGetNextFeature;
  end;
  if (xyPlane = nil) or (yzPlane = nil) or (xzPlane = nil) then
   hr:=S_FALSE;
  Result:=hr;
end;

function OpenSW: IModelDoc2;
begin
{Запуск SW и создание нового документа}
  SW:=CreateOleObject('SldWorks.Application') as ISldWorks;
  if SW= nil  then
      hr:=E_OutOfMemory;
  If Sw.Visible=false then
    Sw.Visible:=true;

  //привязки убираем   и размеры убираем
  Result:=SW.NewPart as IModelDoc2;
  md:=result;
  Razmer:=SW.GetUserPreferenceToggle(SWInputDimValOnCreate);
  SW.SetUserPreferenceToggle(SWInputDimValOnCreate, false);
  privyaz:= md.GetInferenceMode;
  md.SetInferenceMode(false);

end;

function CloseSWShow:Hresult;
var   a: Trec;
begin
  //привязки и размеры включаем
  md.SetInferenceMode(privyaz);
  SW.SetUserPreferenceToggle(SWInputDimValOnCreate, razmer);
  sw.Visible:=true;
  Result:=S_OK;
  end;
end.
