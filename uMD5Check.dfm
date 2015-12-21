object Form1: TForm1
  Left = 374
  Top = 236
  BorderStyle = bsDialog
  Caption = 'MD5'#35745#31639#24037#20855
  ClientHeight = 330
  ClientWidth = 448
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 4
    Top = 26
    Width = 48
    Height = 13
    Caption = #25991#20214#21517#65306
  end
  object lblLink: TLabel
    Left = 8
    Top = 312
    Width = 425
    Height = 13
    Cursor = crHandPoint
    Alignment = taCenter
    AutoSize = False
    Caption = #20316#32773#65306#23567'7'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnClick = lblLinkClick
  end
  object edtFile: TEdit
    Left = 56
    Top = 23
    Width = 337
    Height = 21
    TabOrder = 0
  end
  object btnFile: TButton
    Left = 402
    Top = 21
    Width = 31
    Height = 25
    Caption = '...'
    TabOrder = 2
    OnClick = btnFileClick
  end
  object mmoResult: TMemo
    Left = 8
    Top = 173
    Width = 425
    Height = 129
    TabOrder = 3
  end
  object btnCalc: TButton
    Left = 8
    Top = 142
    Width = 425
    Height = 25
    Caption = #35745#31639'MD5'
    TabOrder = 4
    OnClick = btnCalcClick
  end
  object rdoText: TRadioButton
    Left = 8
    Top = 57
    Width = 81
    Height = 17
    Caption = #25991#26412
    TabOrder = 5
    OnClick = rdoFileClick
  end
  object rdoFile: TRadioButton
    Left = 8
    Top = 4
    Width = 113
    Height = 17
    Caption = #25991#20214
    TabOrder = 1
    OnClick = rdoFileClick
  end
  object mmoText: TMemo
    Left = 8
    Top = 87
    Width = 425
    Height = 49
    TabOrder = 6
  end
  object GroupBox1: TGroupBox
    Left = 112
    Top = 45
    Width = 281
    Height = 36
    Caption = #25991#26412#32534#30721
    TabOrder = 7
    object rdoUtf8: TRadioButton
      Left = 96
      Top = 17
      Width = 73
      Height = 9
      Caption = 'UTF-8'
      TabOrder = 0
    end
    object rdoUnicode: TRadioButton
      Left = 184
      Top = 14
      Width = 81
      Height = 15
      Caption = 'Unicode'
      TabOrder = 1
    end
    object rdoAnsi: TRadioButton
      Left = 8
      Top = 14
      Width = 81
      Height = 17
      Caption = 'ansistring'
      Checked = True
      TabOrder = 2
      TabStop = True
    end
  end
  object OpenDlg: TOpenDialog
    Filter = 'All File|*.*'
    Left = 304
    Top = 114
  end
end
