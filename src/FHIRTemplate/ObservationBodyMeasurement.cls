Class FHIRTemplate.ObservationBodyMeasurement Extends Resource
{

/// JSON出力する際のテンプレート
/// JSONの値の文字列に#(..プロパティ名)#または#(..#パラメータ名)#を指定することで
/// プロパティの値をJSON形式で出力できます。
/// プロパティの型がJSONTemplate.Baseを継承したクラスの場合、
/// そのクラスのテンプレートからJSON出力します。
XData Template [ MimeType = application/json ]
{
{
  "resourceType": "#(..#ResourceType)#",
  "category": [
      {
          "coding": [
              {
                  "system": "http://jpfhir.jp/fhir/Common/ValueSet/bodyMeasurement-code",
                  "code": "exam",
                  "display": "身体検査・観察"
              }
          ],
          "text": "身体検査・観察"
      }
  ],
  "code": "#(..Code)#",
  "effectiveDateTime": "#(..EffectiveDateTime)#",
  "subject": "#(..Patient(FHIRTemplate.Reference))#",
  "status": "final",
  "valueQuantity": "#(..ValueQuantity(FHIRTemplate.DataType.Quantity))#"
}
}

Parameter ResourceType = "Observation";

// MEDIS看護実践用語標準マスタ（看護観察編のOIDを指定してます）https://www.medis.or.jp/4_hyojyun/medis-master/pdf/OID.pdf

Parameter CodeSystem = "urn:oid:1.2.392.200119.4.801";

Property Category As %String;

// Property Code As FHIRTemplate.DataType.CodeableConcept;

Property Code As FHIRCustom.Coding.BodyMeasurementCode;

Property EffectiveDateTime As FHIRTemplate.DataType.TimeStamp;

/// Patientリファレンス
Property Patient As FHIRTemplate.Patient;

Property ValueQuantity As FHIRTemplate.DataType.Quantity;

}
