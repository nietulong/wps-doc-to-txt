

Dim fso,fld,Path
Set fso = WScript.CreateObject("Scripting.Filesystemobject")
Path = fso.GetParentFolderName(WScript.ScriptFullName) '��ȡ�ű������ļ����ַ���
Set fld=fso.GetFolder(Path) 'ͨ��·���ַ�����ȡ�ļ��ж���

Dim Sum,IsChooseDelete,ThisTime
Sum = 0
Dim LogFile
Set LogFile= fso.opentextFile("log.txt",8,true)

Dim List
Set List= fso.opentextFile("ConvertFileList.txt",2,true)

Call LogOut("��ʼ�����ļ�")
Call TreatSubFolder(fld) '���øù��̽��еݹ�������ļ��ж����µ������ļ��������ļ��ж���

Sub LogOut(msg)
    ThisTime=Now
    LogFile.WriteLine(year(ThisTime) & "-" & Month(ThisTime) & "-" & day(ThisTime) & " " & Hour(ThisTime) & ":" & Minute(ThisTime) & ":" & Second(ThisTime) & ": " & msg)
End Sub

Sub TreatSubFolder(fld) 
    Dim File
    Dim ts
    For Each File In fld.Files '�������ļ��ж����µ������ļ�����
        If UCase(fso.GetExtensionName(File)) ="DOC" or UCase(fso.GetExtensionName(File)) ="DOCX" Then
            List.WriteLine(File.Path)
            Sum = Sum + 1
        End If
    Next
'    Dim subfld
 '   For Each subfld In fld.SubFolders '�ݹ�������ļ��ж���
  '      TreatSubFolder subfld
   ' Next
End Sub
List.close

Call LogOut("�ļ���������ɣ����ҵ�" & Sum & "��word�ĵ�")

'If MsgBox("�ļ���������ɣ����ҵ�" & Sum & "��word�ĵ�����ϸ�б���" & vbCrlf & fso.GetFolder(Path).Path & "\ConvertFileList.txt" & vbCrlf & "�����������޸��б�����ɾҪת�����ĵ�" & vbCrlf & vbCrlf & "�Ƿ���Щ�ĵ�ת��ΪPDF��ʽ��", vbYesNo + vbInformation, "�ĵ��������") = vbYes Then
'    If MsgBox("�Ƿ���ת����Ϻ�ɾ��DOC�ĵ�?", vbYesNo+vbInformation, "�Ƿ���ת����Ϻ�ɾ��Դ�ĵ�?") = vbYes Then
 '       IsChooseDelete = MsgBox("���ٴ�ȷ�ϣ��Ƿ���ת����Ϻ�ɾ��DOC�ĵ�?", vbYesNo + vbExclamation, "�Ƿ���ת����Ϻ�ɾ��Դ�ĵ�?")
  '  End If
'else
'    Msgbox("��ȡ��ת������")
'    Wscript.Quit
'End If
'MsgBox "���ڿ�ʼת��ǰ�˳�����Word�ĵ������ĵ�ռ�ô�����", vbOKOnly + vbExclamation, "����"

'����Word���󣬼���WPS
Const wdFormatText = 2
On Error Resume Next
Set WordApp = CreateObject("Word.Application")
' try to connect to wps
If WordApp Is Nothing Then '����WPS
    Set WordApp = CreateObject("WPS.Application")
    If WordApp Is Nothing Then
        Set WordApp = CreateObject("KWPS.Application")
        If WordApp Is Nothing Then
            MsgBox "����������office 2010�����ϰ汾������WPS��" & vbCrlf & "����ʹ�ñ�����ǰ��װoffice word ��WPS,���򱾳����޷�ʹ��", vbCritical + vbOKOnly, "�޷�ת��"
            WScript.Quit
        End If
    End If
End If
On Error Goto 0

WordApp.Visible=false '������ͼ���ɼ�

Sum = 0
Dim FilePath,FileLine
Set List= fso.opentextFile("ConvertFileList.txt",1,true)
Do While List.AtEndOfLine <> True 
    FileLine=List.ReadLine
    If FileLine <> "" and Mid(FileLine,1,2) <> "~$" Then
        Sum = Sum + 1 '��ȡ�û��޸ĺ���ļ��б�����
    End If
loop
List.close
'MsgBox "���ڿ�ʼת�������������й����е���Word����"&vbCrlf&"��ֱ����С��Word���ڣ���Ҫ�ر�!"&vbCrlf&"��ֱ����С��Word���ڣ���Ҫ�ر�!"&vbCrlf&"��ֱ����С��Word���ڣ���Ҫ�ر�!"&vbCrlf&"��Ҫ������˵���飡�رջᵼ�½ű��˳�", vbOKOnly + vbExclamation, "����"
Dim Finished
Finished = 0
Set List= fso.opentextFile("ConvertFileList.txt",1,true)
Do While List.AtEndOfLine <> True 
    FilePath=List.ReadLine
    If Mid(FilePath,1,2) <> "~$" Then '������word��ʱ�ļ�
        Set objDoc = WordApp.Documents.Open(FilePath)
        'WordApp.Visible=false '������ͼ���ɼ�����������ʱ��Ϊ�������⵼�µĿɼ���
        '�������������⣬����������������ɶ�궨���������������һ��һ���ģ�������û��
        If WordApp.Visible = true Then
            WordApp.ActiveDocument.ActiveWindow.WindowState = 2 'wdWindowStateMinimize
        End If
        objDoc.SaveAs Left(FilePath,InstrRev(FilePath,".")) & "txt", wdFormatText '���ΪTXT�ĵ�
        LogOut("�ĵ�" & FilePath & "��ת����ɡ�(" & Finished & "/" & Sum & ")")
        WordApp.ActiveDocument.Close  
        Finished = Finished + 1
    End If
    If IsChooseDelete = vbYes Then
        fso.deleteFile FilePath
        LogOut("�ļ�" & FilePath & "�ѱ��ɹ�ɾ��")
    End If
loop
'ɨβ����ʼ
List.close
LogOut("�ĵ�ת�������")
LogFile.close 
'ConvertFileList.txt��log.txtҪ�Զ�ɾ������ȥ���������п�ͷ������
fso.deleteFile "ConvertFileList.txt"
fso.deleteFile "log.txt"

Dim Msg
Msg = "�ѳɹ�ת��" & Finished & "���ļ�"
If IsChooseDelete = vbYes Then
    Msg=Msg + "���ɹ�ɾ��Դ�ļ�"
End If
'MsgBox Msg & vbCrlf & "��־�ļ���" & fso.GetFolder(Path).Path & "\log.txt"
Set fso = nothing
WordApp.Quit
Wscript.Quit