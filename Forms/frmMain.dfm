object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'FormMain'
  ClientHeight = 571
  ClientWidth = 828
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 828
    Height = 571
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Dane wej'#347'ciowe'
      ExplicitWidth = 281
      ExplicitHeight = 301
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 820
        Height = 543
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 828
        ExplicitHeight = 571
        object seSuppliersAmount: TSpinEdit
          Left = 24
          Top = 28
          Width = 73
          Height = 22
          MaxValue = 50
          MinValue = 1
          TabOrder = 0
          Value = 1
          OnChange = actRebuildGridExecute
        end
        object seDemandersAmount: TSpinEdit
          Left = 24
          Top = 56
          Width = 73
          Height = 22
          MaxValue = 50
          MinValue = 1
          TabOrder = 1
          Value = 1
          OnChange = actRebuildGridExecute
        end
        object gridInputData: TStringGrid
          Left = 111
          Top = 1
          Width = 708
          Height = 541
          Align = alRight
          ColCount = 12
          DefaultColWidth = 55
          DefaultRowHeight = 30
          FixedCols = 0
          RowCount = 12
          FixedRows = 0
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
          ScrollBars = ssNone
          TabOrder = 2
          ExplicitLeft = 119
          ExplicitHeight = 569
        end
        object btnNorthWest: TButton
          Left = 24
          Top = 112
          Width = 75
          Height = 25
          Caption = 'Uruchom'
          TabOrder = 3
          OnClick = btnNorthWestClick
        end
      end
    end
    object TabIteration1: TTabSheet
      Caption = 'Iteracja 1'
      ImageIndex = 1
      TabVisible = False
      ExplicitLeft = -20
      ExplicitTop = 80
      ExplicitWidth = 281
      ExplicitHeight = 301
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 820
        Height = 543
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 120
        ExplicitTop = 96
        ExplicitWidth = 185
        ExplicitHeight = 41
        object Panel3: TPanel
          Left = 399
          Top = 1
          Width = 10
          Height = 541
          Align = alLeft
          Color = clMedGray
          ParentBackground = False
          TabOrder = 0
          ExplicitLeft = 417
        end
        object Panel4: TPanel
          Left = 409
          Top = 1
          Width = 410
          Height = 541
          Align = alClient
          Caption = 'Panel4'
          TabOrder = 1
          ExplicitLeft = 405
          object gridFactors: TStringGrid
            Left = 1
            Top = 33
            Width = 408
            Height = 408
            Align = alClient
            ColCount = 12
            DefaultColWidth = 55
            DefaultRowHeight = 30
            FixedCols = 0
            RowCount = 12
            FixedRows = 0
            ScrollBars = ssNone
            TabOrder = 0
            ExplicitTop = 32
            ExplicitHeight = 409
          end
          object Panel5: TPanel
            Left = 1
            Top = 456
            Width = 408
            Height = 84
            Align = alBottom
            TabOrder = 1
            ExplicitLeft = -4
            ExplicitTop = 462
            object Label1: TLabel
              Left = 1
              Top = 1
              Width = 406
              Height = 82
              Align = alClient
              Alignment = taCenter
              Caption = 'Zysk ='
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -15
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentFont = False
              Layout = tlCenter
              ExplicitLeft = 5
              ExplicitTop = 32
              ExplicitWidth = 396
              ExplicitHeight = 18
            end
          end
          object Panel6: TPanel
            Left = 1
            Top = 441
            Width = 408
            Height = 15
            Align = alBottom
            Color = clBtnShadow
            ParentBackground = False
            TabOrder = 2
            ExplicitLeft = 64
            ExplicitTop = 415
            ExplicitWidth = 297
            ExplicitHeight = 41
          end
          object Panel9: TPanel
            Left = 1
            Top = 1
            Width = 408
            Height = 32
            Align = alTop
            Caption = 'Tabela wska'#378'nik'#243'w optymalno'#347'ci'
            TabOrder = 3
            ExplicitLeft = 2
            ExplicitTop = 9
          end
        end
        object Panel7: TPanel
          Left = 1
          Top = 1
          Width = 398
          Height = 541
          Align = alLeft
          Caption = 'Panel7'
          TabOrder = 2
          ExplicitLeft = 11
          object gridResult: TStringGrid
            Left = 1
            Top = 33
            Width = 396
            Height = 507
            Align = alClient
            ColCount = 12
            DefaultColWidth = 55
            DefaultRowHeight = 30
            FixedCols = 0
            RowCount = 12
            FixedRows = 0
            ScrollBars = ssNone
            TabOrder = 0
            ExplicitTop = 32
            ExplicitHeight = 508
          end
          object Panel8: TPanel
            Left = 1
            Top = 1
            Width = 396
            Height = 32
            Align = alTop
            Caption = 'Rozwi'#261'zanie bazowe'
            TabOrder = 1
          end
        end
      end
    end
  end
  object ActionList: TActionList
    Left = 440
    Top = 392
    object actRebuildGrid: TAction
      Caption = 'actRebuildGrid'
      OnExecute = actRebuildGridExecute
    end
  end
end
