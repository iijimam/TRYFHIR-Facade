Class FHIRTemplate.BundlePatientObservation Extends FHIRTemplate.Resource
{

XData Template [ MimeType = application/json ]
{
{
  "resourceType": "#(..#ResourceType)#",
  "type": "searchset",
  "total":"#(..Total)#",
  "entry": [
    "#(..Patient(FHIRTemplate.Bundle.entry))#",
    "#(..Observation(FHIRTemplate.Bundle.entry))#"
  ]
  }
}

Parameter ResourceType = "Bundle";

Property Total As %Integer;

Property Patient As FHIRTemplate.Patient;

Property Observation As list Of FHIRTemplate.ObservationBodyMeasurement;

}
