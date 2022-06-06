/// CodableConcept
Class FHIRTemplate.DataType.CodeableConceptBase Extends JSONTemplate.Base
{

Parameter CodeSystem;

/// JSON出力する際のテンプレート
XData Template [ MimeType = application/json ]
{
{
	"coding": [
		{
			"system": "#(..#CodeSystem)#",
			"code": "#(..code)#",
			"display": "#(..display)#"
		}
	],
	"text": "#(..text)#"
}
}

Property system As %String;

Property code As %String;

Property display As %String;

Property text As %String;

}
