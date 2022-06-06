Class FHIRFacade.BuildResource
{

ClassMethod Test(ByRef json As %DynamicObject)
{
    #dim ex As %Exception.AbstractException
    set status=$$$OK
    try {
        set input={}
        set input.PID="498374"
        $$$ThrowOnError(..Bundle(input,.json,.streamid))
        write streamid
    }
    catch ex {
        set status=ex.AsStatus()
    }
    return status
}

ClassMethod Patient(input As %DynamicObject, ByRef json As %DynamicObject, ByRef QuickStreamId As %String) As %Status
{
    #dim ex As %Exception.AbstractException
    set status=$$$OK
    try {
        set sql="SELECT JSON_OBJECT('PatientId':PID, 'FirstName':Given, 'LastName':Family, 'FirstNameKana':GivenKana, 'LastNameKana':FamilyKana, 'DOB':DOB, 'PostalCode':Zip, 'Address':Pref||City||Address, 'Phone':Tel, 'Gender':Gender) As json FROM ISJHospital.Patient where PID=?"
        $$$ThrowOnError(##class(FHIRFacade.CollectData).RunQuery(sql,.rset,input.PID))
        if rset.%Size()=0 {
            throw ##class(%Exception.General).%New(5001,"指定の患者ID："_input.PID_"の患者は存在しません")
        }
        $$$ThrowOnError(##class(FHIRFacade.SetResourceData).Patient2(rset.%Get(0),.patient))
        kill rset
        //genderの変換
        set patient.Gender=$select(patient.Gender="Male":1,1:2)

        set ret=patient.OutputToFile("patient.json")
        //QuickStreamに作成したBundleリソースを保存
        set patientQS=##class(HS.SDA3.QuickStream).%New()
        set QuickStreamId=patientQS.%Id()
        $$$ThrowOnError(patient.OutputToStream(patientQS))
        //検証実行のため、QuickStreamに保存したBundleリソースをJSONのダイナミックオブジェクトに変換
        set json={}.%FromJSON(patientQS)
        //検証実行
        $$$ThrowOnError(##class(FHIRFacade.SetResourceData).Validate(json))

    }
    catch ex {
        set status=ex.AsStatus()
    }
    return status
}

ClassMethod Bundle(input As %DynamicObject, ByRef json As %DynamicObject, ByRef QuickStreamId As %String) As %Status
{
    #dim ex As %Exception.AbstractException
    set status=$$$OK
    try {
        //Bundle作成
        set bundle=##class(FHIRCustom.BundlePatientObservation).%New()

        //Patient情報取得
        set sql="SELECT JSON_OBJECT('PatientId':PID, 'FirstName':Given, 'LastName':Family, 'FirstNameKana':GivenKana, 'LastNameKana':FamilyKana, 'DOB':DOB, 'PostalCode':Zip, 'Address':Pref||City||Address, 'Phone':Tel, 'Gender':Gender) As json FROM ISJHospital.Patient where PID=?"
        $$$ThrowOnError(##class(FHIRFacade.CollectData).RunQuery(sql,.rset,input.PID))
        if rset.%Size()=0 {
            throw ##class(%Exception.General).%New(5001,"指定の患者ID："_input.PID_"の患者は存在しません")
        }
        $$$ThrowOnError(##class(FHIRFacade.SetResourceData).Patient2(rset.%Get(0),.patient))
        kill rset

        //BundleにPatientリソースを割り当てる
        do bundle.Resource.Insert(patient)

        kill rset
        //Observation情報取得（複数件ある）
        set sql="SELECT JSON_OBJECT('code':LabTestCode, 'display':LabTestText, 'value':Value, 'unit':Unit, 'EffectiveDateTime':LabTestDateTime) as json FROM ISJHospital.Observation WHERE PID=?"
        $$$ThrowOnError(##class(FHIRFacade.CollectData).RunQuery(sql,.rset,input.PID))
        set observationcount=rset.%Size()
        for i=0:1:(observationcount-1) {
            $$$ThrowOnError(##class(FHIRFacade.SetResourceData).ObservationBodyMeasurement(rset.%Get(i),.observation))
            //Patientのリファレンスを登録
            set observation.Patient=patient
            //BundleにObservationリソース割り当てる
            do bundle.Resource.Insert(observation)
            kill observation
        }

        set bundle.Total=observationcount+1  // +1 はPatientリソース数を追加
        set ret=bundle.OutputToFile("bundle2.json")
        //QuickStreamに作成したBundleリソースを保存
        set bundleQS=##class(HS.SDA3.QuickStream).%New()
        set QuickStreamId=bundleQS.%Id()
        $$$ThrowOnError(bundle.OutputToStream(bundleQS))
        //検証実行のため、QuickStreamに保存したBundleリソースをJSONのダイナミックオブジェクトに変換
        set json={}.%FromJSON(bundleQS)
        //検証実行
        $$$ThrowOnError(##class(FHIRFacade.SetResourceData).Validate(json))

    }
    catch ex {
        set status=ex.AsStatus()
    }
    return status
}

}
