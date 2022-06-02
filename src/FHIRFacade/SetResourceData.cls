Class FHIRFacade.SetResourceData
{

ClassMethod Validate(in As %DynamicObject) As %Status
{
	#dim ex As %Exception.AbstractException
	set tSC=$$$OK
	try {
		set schema = ##class(HS.FHIRServer.Schema).LoadSchema("HL7v40")
		set resourceValidator = ##class(HS.FHIRServer.Util.ResourceValidator).%New(schema)
		do resourceValidator.ValidateResource(in) 
	}catch ex {
		set tSC=ex.AsStatus()
	}
	quit tSC
}

ClassMethod Patient2(in As %DynamicObject, ByRef patient As FHIRTemplate.Patient) As %Status
{
    kill %objlasterror
    set patient=##class(FHIRTemplate.Patient).%New(in)
    //インスタンスが生成できないとき
    if patient=$$$NULLOREF {
        set err=$system.Status.Error(5001,$system.Status.GetErrorText(%objlasterror))
        return err
    }
    //genderの変換
    set patient.Gender=$select(patient.Gender="Male":1,1:2)
    return $$$OK
}

ClassMethod ObservationBodyMeasurement(in As %DynamicObject, ByRef observation As FHIRTemplate.ObservationBodyMeasurement) As %Status
{
    #dim ex As %Exception.AbstractException
    set status=$$$OK
    try {
        set observation=##class(FHIRTemplate.ObservationBodyMeasurement).%New()
        /*
        set code=##class(FHIRTemplate.DataType.CodeableConcept).%New()
        set code.system=observation.#CodeSystem
        set code.code=in.code
        set code.display=in.display
        */
        set code=##class(FHIRCustom.Coding.BodyMeasurementCode).GetByCode(in.display,in.unit)      
        set observation.Code=code
        set observation.EffectiveDateTime=$ZDATETIMEH(in.EffectiveDateTime,3)
        set valueQuantity=##class(FHIRTemplate.DataType.Quantity).%New()
        set valueQuantity.value=+in.value
        set valueQuantity.unit=in.unit
        set valueQuantity.code=code.code
        set observation.ValueQuantity=valueQuantity
    }
    catch ex {
        set status=ex.AsStatus()
    }
    return status
}

}
