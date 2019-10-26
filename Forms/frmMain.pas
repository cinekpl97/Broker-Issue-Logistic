unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin,
  Vcl.ExtCtrls, Vcl.Grids, System.Actions, Vcl.ActnList, System.Generics.Collections,
  Vcl.ComCtrls;

type
  TInteger2DArray = array of array of Integer;

type
  TCoordinates = class
    I, J : Integer;
    constructor Create(tempI,tempJ : Integer);
  end;

type
  TFormMain = class(TForm)
    Panel1: TPanel;
    seSuppliersAmount: TSpinEdit;
    seDemandersAmount: TSpinEdit;
    gridInputData: TStringGrid;
    btnNorthWest: TButton;
    ActionList: TActionList;
    actRebuildGrid: TAction;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabIteration1: TTabSheet;
    Panel2: TPanel;
    gridResult: TStringGrid;
    Panel3: TPanel;
    Panel4: TPanel;
    gridFactors: TStringGrid;
    Panel5: TPanel;
    Label1: TLabel;
    Panel7: TPanel;
    Panel6: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    procedure btnNorthWestClick(Sender: TObject);
    procedure actRebuildGridExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure FillGridWithExampleData;
    procedure CountGains(gainArray, transportCostsArray : TInteger2DArray;
                         suppliersCostsArray, demandersCostsArray : array of Integer;
                         suppliersAmount, demandersAmount : Integer);
    procedure SetPlanValues(planArray : TInteger2DArray; supplyArray, demandArray : array of Integer);
    procedure SetAlfasAndBetas(planArray, gainArray : TInteger2DArray; var alfasArray, betasArray : array of Integer);
    procedure SetFactors(factorArray, planArray, gainArray : TInteger2DArray; alfasArray, betasArray : array of Integer);
    procedure SearchPathAndSetNewPlan(factorArray, planArray : TInteger2DArray; Imax, Jmax : Integer);
    procedure PrintIterationData(planArray, factorArray, gainArray : TInteger2DArray; alfasArray, betasArray : array of Integer);
    function CopyList(list : TList<TCoordinates>) : TList<TCoordinates>;
  public
  {}
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

constructor TCoordinates.Create(tempI, tempJ : Integer);
begin
  I := tempI;
  J := tempJ;
end;

procedure TFormMain.actRebuildGridExecute(Sender: TObject);
begin
  gridInputData.ColCount := seDemandersAmount.Value + 3;
  gridInputData.RowCount := seSuppliersAmount.Value + 3;
end;

procedure TFormMain.btnNorthWestClick(Sender: TObject);
  var
  {
    supplyArray - tablica podazy
    demandArray - tablica popytu
    suppliersCostsArray - tablica cen kupa od dostawcow
    demandersCostsArray - tablica cen sprzedazy
    transportCostsArray - tablica kosztow transportu
    gainArray - tablica zysku
    planArray - tablica planu (wartosci z komorek)
    alfasArray - tablica z alfami
    betasArray - tablica z betami
    factorArray - tablica wspó³czynników
  }
  supplyArray, demandArray, suppliersCostsArray, demandersCostsArray, alfasArray, betasArray  : array of Integer;
  gainArray, transportCostsArray, planArray, factorArray : TInteger2DArray;
  suppliersAmount, demandersAmount, I, J  : Integer;
  max: Integer;
  Imax: Integer;
  Jmax: Integer;
  endOfOptimalization : Boolean;
begin
  suppliersAmount := seSuppliersAmount.Value;
  demandersAmount := seDemandersAmount.Value;
  SetLength(supplyArray, suppliersAmount + 1);
  SetLength(demandArray, demandersAmount + 1);
  SetLength(alfasArray, suppliersAmount + 1);
  SetLength(betasArray, demandersAmount + 1);

  supplyArray[suppliersAmount] := 0;
  demandArray[demandersAmount] := 0;

  //UZUPELNIANIE POPYTU I PODAZY
  for I := 0 to suppliersAmount - 1 do begin
    supplyArray[I] := StrToInt(gridInputData.Cells[1, I + 3]);
    demandArray[demandersAmount] := demandArray[demandersAmount] + supplyArray[I];
  end;
  for I := 0 to demandersAmount - 1 do begin
    demandArray[I] := StrToInt(gridInputData.Cells[I + 3, 1]);
    supplyArray[suppliersAmount] := supplyArray[suppliersAmount] + demandArray[I];
  end;


  //TWORZENIE DWUWYMIAROWYCH TABLIC ZYSKOW I PLANOW
  SetLength(gainArray, suppliersAmount + 1);
  SetLength(planArray, suppliersAmount + 1);
  for I := 0 to suppliersAmount do begin
    SetLength(gainArray[I], demandersAmount + 1);
    SetLength(planArray[I], demandersAmount + 1);
  end;


  //TWORZENIE DWUWYMIAROWEJ TABLICY KOSZTOW TRANSPORTU
  SetLength(transportCostsArray, suppliersAmount + 1);
  for I := 0 to suppliersAmount do begin
    SetLength(transportCostsArray[I], demandersAmount + 1);
  end;

  //UZUPELNIANIE TABLICY KOSZTOW TRANSPORTU
  for I := 0 to suppliersAmount - 1 do begin
    for J := 0 to demandersAmount - 1 do begin
      transportCostsArray[I][J] := StrToInt(gridInputData.Cells[J + 3, I + 3]);
    end;

    transportCostsArray[I][demandersAmount] := 0;
  end;

  for J := 0 to demandersAmount do begin
    transportCostsArray[suppliersAmount][J] := 0;
  end;


  //UZUPELNIANIE CEN KUPNA I SPRZEDAZY
  SetLength(suppliersCostsArray, suppliersAmount + 1);
  SetLength(demandersCostsArray, demandersAmount + 1);

  for I := 0 to suppliersAmount - 1 do begin
    suppliersCostsArray[I] := StrToInt(gridInputData.Cells[0, I + 3]);
  end;
  suppliersCostsArray[suppliersAmount] := 0;
  for I := 0 to demandersAmount - 1 do begin
    demandersCostsArray[I] := StrToInt(gridInputData.Cells[I + 3, 0]);
  end;
  demandersCostsArray[demandersAmount] := 0;

  SetLength(factorArray, suppliersAmount + 1);
  for I := 0 to suppliersAmount do begin
    SetLength(factorArray[I], demandersAmount + 1);
  end;


  CountGains(gainArray, transportCostsArray, suppliersCostsArray, demandersCostsArray,
             suppliersAmount, demandersAmount);

  SetPlanValues(planArray, supplyArray, demandArray);

  endOfOptimalization := False;
//  while not endOfOptimalization do begin

    SetAlfasAndBetas(planArray, gainArray, alfasArray, betasArray);

    SetFactors(factorArray, planArray, gainArray, alfasArray, betasArray);

    TabIteration1.TabVisible := True;

    PrintIterationData(planArray, factorArray, gainArray, alfasArray, betasArray);

      //findMax
    max := factorArray[0][0];
    for I := 0 to Length(planArray) - 1 do begin
      for J := 0 to Length(planArray[I]) - 1 do begin
        if factorArray[I][J] > max then begin
          max := factorArray[I][J];
          Imax := I;
          Jmax := J;
        end;
      end;
    end;

//    if max > 0 then begin
      SearchPathAndSetNewPlan(factorArray, planArray, Imax, Jmax);
//    end else begin
//      endOfOptimalization := True;
//    end;

//  end;

  for I := 0 to length(gainArray) - 1 do begin
    SetLength(gainArray[I], 0);
  end;

  for I := 0 to Length(transportCostsArray) - 1 do begin
    SetLength(transportCostsArray[I], 0);
  end;

  for I := 0 to Length(planArray) - 1 do begin
    SetLength(planArray[I], 0);
  end;

  SetLength(supplyArray, 0);
  SetLength(demandArray, 0);
  SetLength(suppliersCostsArray, 0);
  SetLength(demandersCostsArray, 0);
  SetLength(transportCostsArray, 0);
  SetLength(gainArray, 0);
  SetLength(planArray, 0);
  SetLength(alfasArray, 0);
  SetLength(betasArray, 0);
  FreeAndNil(suppliersCostsArray);
  FreeAndNil(demandersCostsArray);
  FreeAndNil(transportCostsArray);
  FreeAndNil(demandArray);
  FreeAndNil(supplyArray);
  FreeAndNil(gainArray);
  FreeAndNil(planArray);
  FreeAndNil(alfasArray);
  FreeAndNil(betasArray);
end;

procedure TFormMain.CountGains(gainArray, transportCostsArray : TInteger2DArray;
                               suppliersCostsArray, demandersCostsArray : array of Integer;
                               suppliersAmount, demandersAmount : Integer);
var
  I, J : Integer;
begin
  for I := 0 to suppliersAmount - 1 do begin
    for J := 0 to demandersAmount - 1 do begin
      gainArray[I][J] := demandersCostsArray[J] - suppliersCostsArray[I] - transportCostsArray[I][J];
    end;
  end;
end;

procedure TFormMain.SetPlanValues(planArray : TInteger2DArray; supplyArray, demandArray : array of Integer);
var
  I, J : Integer;
begin
  for I := 0 to Length(supplyArray) - 1 do begin
    for J := 0 to Length(demandArray) - 1 do begin
      if supplyArray[I] > demandArray[J] then begin
        planArray[I][J] := demandArray[J];
        supplyArray[I] := supplyArray[I] - demandArray[J];
        demandArray[J] := 0;
      end else begin
        planArray[I][J] := supplyArray[I];
        demandArray[J] := demandArray[J] - supplyArray[I];
        supplyArray[I] := 0;
      end;
    end;
  end;

//  for J := 0 to Length(demandArray) - 1 do begin
//    planArray[Length(supplyArray) - 1][J] := demandArray[J];
//    demandArray[J] := 0;
//  end;

//  planArray[Length(supplyArray)][Length(demandArray)] := supplyArray[Length(supplyArray)]

end;

procedure TFormMain.SetAlfasAndBetas(planArray, gainArray : TInteger2DArray; var alfasArray, betasArray : array of Integer);
var
  I, J : Integer;
  finish : boolean;
  isAlfaSetArray, isBetaSetArray : array of Boolean;
begin

  SetLength(isAlfaSetArray, length(alfasArray));
  SetLength(isBetaSetArray, length(betasArray));
  for I := 1  to Length(isAlfaSetArray) - 1 do begin
    isAlfaSetArray[I] := False;
  end;
  isAlfaSetArray[0] := True;
  alfasArray[0] := 0;

  for I := 0  to Length(isBetaSetArray) - 1 do begin
    isBetaSetArray[I] := False;
  end;

  finish := false;
  while not finish do begin
    finish := true;
    for I := 0 to length(alfasArray) - 1 do begin
      for J := 0 to length(betasArray) - 1 do begin
        if planArray[I][J] = 0 then begin
          Continue;
        end else begin
          if (isAlfaSetArray[I]) and (not isBetaSetArray[J]) then begin
            betasArray[J] := gainArray[I][J] - alfasArray[I];
            isBetaSetArray[J] := True;
          end else if (isBetaSetArray[J]) and (not IsAlfaSetArray[I]) then begin
            alfasArray[I] := gainArray[I][J] - betasArray[J];
            isAlfaSetArray[I] := True;
          end;

          if finish and ((not IsAlfaSetArray[I]) or (not isBetaSetArray[J])) then finish := false;
        end;
      end;
    end;
  end;




  SetLength(isAlfaSetArray, 0);
  SetLength(isBetaSetArray, 0);
  FreeAndNil(isAlfaSetArray);
  FreeAndNil(isBetaSetArray);
end;

procedure TFormMain.SetFactors(factorArray, planArray, gainArray : TInteger2DArray; alfasArray, betasArray : array of Integer);
var
 I, J : Integer;
begin
  for I := 0 to Length(alfasArray) - 1 do begin
    for J := 0 to Length(betasArray) - 1 do begin
      if planArray[I][J] <> 0 then begin
        Continue;
      end else begin
        factorArray[I][J] := gainArray[I][J] - alfasArray[I] - betasArray[J];
      end;
    end;
  end;
end;

function TFormMain.CopyList(list : TList<TCoordinates>) : TList<TCoordinates>;
var
  I: Integer;
begin
  Result := TList<TCoordinates>.Create;
  for I := 0 to list.Count - 1 do begin
    Result.Add(TCoordinates.Create(list.Items[I].I, list.Items[I].J));
  end;

end;

procedure TFormMain.SearchPathAndSetNewPlan(factorArray, planArray : TInteger2DArray; Imax, Jmax : Integer);
var
  I, J, listNumber : Integer;
  path : TList<TCoordinates>;
  pathsList : TList<TList<TCoordinates>>;
  pathElement : TCoordinates;
  toDelete: Boolean;
  toNewList: Boolean;
  currentJ: Integer;
  currentI: Integer;
  skipElement: Boolean;
  tmpI: Integer;
  tmpJ : Integer;
  min: Integer;
begin
  path := TList<TCoordinates>.Create;
  pathsList := TList<TList<TCoordinates>>.Create;
  pathElement := TCoordinates.Create(0, 0);

  pathElement.I := Imax;
  pathElement.J := Jmax;
  path.Add(TCoordinates.Create(Imax, Jmax));
  pathsList.Add(path);

  listNumber := 0;
  while listNumber < pathsList.Count do begin
    begin
      repeat
        toDelete := True;
        toNewList := False;
        if  pathsList[listNumber].Count mod 2 = 0 then begin
          currentJ := pathsList[listNumber].Items[pathsList[listNumber].Count - 1].J;
          for currentI := 0 to Length(planArray) - 1 do begin
            skipElement := False;
            for I := 0 to pathsList[listNumber].Count - 1 do begin
              if (planArray[currentI][currentJ] = 0) or ((pathsList[listNumber].Items[I].I = currentI) and (pathsList[listNumber].Items[I].J = currentJ)) then begin
                skipElement := True;
                Break;
              end;
            end;
            if skipElement then begin
              Continue;
            end else begin
              if not toNewList then begin
                toDelete := False;
                toNewList := True;
                pathElement.I := currentI;
                pathElement.J := currentJ;
                pathsList[listNumber].Add(TCoordinates.Create(currentI, currentJ));
              end else begin
              //
                pathsList.Add(CopyList(pathsList[listNumber]));
                pathsList[pathsList.Count - 1].Delete(pathsList[pathsList.Count - 1].Count - 1);
                pathElement.I := currentI;
                pathElement.J := currentJ;
                pathsList[pathsList.Count - 1].Add(TCoordinates.Create(currentI, currentJ));
              end;
            end;
          end;
        end else begin
          currentI := pathsList[listNumber].Items[pathsList[listNumber].Count - 1].I;
          for currentJ := 0 to Length(planArray[0]) - 1 do begin
            skipElement := False;
            for J := 0 to pathsList[listNumber].Count - 1 do begin
              if (planArray[currentI][currentJ] = 0) or ((pathsList[listNumber].Items[J].I = currentI) and (pathsList[listNumber].Items[J].J = currentJ)) then begin
                skipElement := True;
                Break;
              end;
            end;

            if skipElement then begin
              Continue;
            end else begin
              if not toNewList then begin
                toDelete := False;
                toNewList := True;
                pathElement.I := currentI;
                pathElement.J := currentJ;
                pathsList[listNumber].Add(TCoordinates.Create(currentI, currentJ));
              end else begin
                pathsList.Add(CopyList(pathsList[listNumber]));
                pathsList[pathsList.Count - 1].Delete(pathsList[pathsList.Count - 1].Count - 1);
                pathElement.I := currentI;
                pathElement.J := currentJ;
                pathsList[pathsList.Count - 1].Add(TCoordinates.Create(currentI, currentJ));
              end;
            end;
          end;
        end;
      until ((pathsList[listNumber].Items[0].J = pathsList[listNumber].Items[pathsList[listNumber].Count - 1].J) or (toDelete));
    end;

    if toDelete then begin
      pathsList[listNumber].Free;
      pathsList.Delete(listNumber);
    end else begin
      Inc(listNumber);
    end;
  end;

  I := 1;
  while I < pathsList.Count do begin
    if pathsList[0].Count > pathsList[1].Count then begin
      pathsList[0].Free;
      pathsList.Delete(0);
    end else begin
      pathsList[1].Free;
      pathsList.Delete(1);
    end;
  end;

  //Ustalanie wartoœci do zmiany wartoœci w planie +-+-
  I := 3;
  min := planArray[pathsList[0].Items[1].I][pathsList[0].Items[1].J];
  while I < pathsList[0].Count do begin
    if planArray[pathsList[0].Items[I].I][pathsList[0].Items[I].J] < min then begin
      min := planArray[pathsList[0].Items[I].I][pathsList[0].Items[I].J];
    end;
    I := I + 2;
  end;

  for I := 0 to pathsList[0].Count - 1 do begin
    if I mod 2 = 0 then begin
      planArray[pathsList[0].Items[I].I][pathsList[0].Items[I].J] := planArray[pathsList[0].Items[I].I][pathsList[0].Items[I].J] + min;
    end else begin
      planArray[pathsList[0].Items[I].I][pathsList[0].Items[I].J] := planArray[pathsList[0].Items[I].I][pathsList[0].Items[I].J] - min;
    end;
  end;

  pathsList[0].Free;
  pathsList.Free;
end;

procedure TFormMain.PrintIterationData(planArray, factorArray, gainArray : TInteger2DArray; alfasArray, betasArray : array of Integer);
var
  gain, I, J: Integer;
begin
  gridResult.ColCount := Length(planArray[0]) + 2;
  gridResult.RowCount := Length(planArray) + 2;

  gridFactors.ColCount := Length(planArray[0]);
  gridFactors.RowCount := Length(planArray);

  gain := 0;
  //Uzupe³nianie bez alf i bet
  for I := 0 to length(planArray) - 1 do begin
    for J := 0 to length(planArray[0]) - 1 do begin
      gain := gain + gainArray[I][J] * planArray[I][J];
      gridFactors.Cells[J, I] := IntToStr(factorArray[I][J]);
      gridResult.Cells[J + 1, I + 1] := IntToStr(planArray[I][J]);
    end;
  end;



  gridResult.Cells[0, Length(alfasArray) + 1] := 'Beta';
  gridResult.Cells[length(betasArray) + 1, 0] := 'Alfa';

  for I := 1 to Length(alfasArray) do begin
    gridResult.Cells[0, I] := 'D' + IntToStr(I);
    gridResult.Cells[length(betasArray) + 1, I] := IntToStr(alfasArray[I - 1]);
  end;
  for I := 1 to Length(betasArray) do begin
    gridResult.Cells[I, 0] := 'O' + IntToStr(I);
    gridResult.Cells[I, length(alfasArray) + 1] := IntToStr(betasArray[I - 1]);
  end;

  gridResult.Cells[0, Length(alfasArray)] := 'Df';
  gridResult.Cells[Length(betasArray), 0] := 'Of';


  Label1.Caption := 'Zysk = ' + IntToStr(gain);
end;

procedure TFormMain.FillGridWithExampleData;
begin
  gridInputData.Cells[0, 2] := 'Koszt kupna';
  gridInputData.Cells[0, 3] := '10';
  gridInputData.Cells[0, 4] := '12';

  gridInputData.Cells[1, 2] := 'Poda¿';
  gridInputData.Cells[1, 3] := '20';
  gridInputData.Cells[1, 4] := '30';

  gridInputData.Cells[2, 0] := 'Cena sprzedazy';
  gridInputData.Cells[2, 1] := 'Popyt';

  gridInputData.Cells[2, 2] := '';
  gridInputData.Cells[2, 3] := 'D1';
  gridInputData.Cells[2, 4] := 'D2';

  gridInputData.Cells[3, 0] := '30';
  gridInputData.Cells[3, 1] := '10';
  gridInputData.Cells[3, 2] := 'O1';
  gridInputData.Cells[3, 3] := '8';
  gridInputData.Cells[3, 4] := '12';

  gridInputData.Cells[4, 0] := '25';
  gridInputData.Cells[4, 1] := '28';
  gridInputData.Cells[4, 2] := 'O2';
  gridInputData.Cells[4, 3] := '14';
  gridInputData.Cells[4, 4] := '9';

  gridInputData.Cells[5, 0] := '30';
  gridInputData.Cells[5, 1] := '27';
  gridInputData.Cells[5, 2] := 'O3';
  gridInputData.Cells[5, 3] := '17';
  gridInputData.Cells[5, 4] := '19';
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  seSuppliersAmount.Value := 2;
  seDemandersAmount.Value := 3;

  FillGridWithExampleData;
end;

end.
