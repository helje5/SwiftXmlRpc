enum TestData {
  
  static let sampleSumCall =
    """
    <?xml version="1.0" encoding="ISO-8859-1"?>
    <methodCall>
       <methodName>sample.sum</methodName>
       <params>
          <param>
             <value><int>17</int></value>
          </param>
          <param>
             <value><int>13</int></value>
          </param>
       </params>
    </methodCall>
    """

  static let sampleSumResponse =
    """
    <?xml version="1.0" encoding="ISO-8859-1"?>
    <methodResponse>
       <params>
          <param>
             <value><int>30</int></value>
          </param>
       </params>
    </methodResponse>
    """
  
  static let installCall =
  """
  <?xml version="1.0"?><methodCall><methodName>setInstallModeWithWhitelist</methodName><params><param><value><boolean>1</boolean></value></param><param><value><i4>30</i4></value></param><param><value><array><data><value><struct><member><name>ADDRESS</name><value><string>3014F7XXXXXXXXYYYY8CBEEE</string></value></member><member><name>KEY</name><value><string>FBCABCDEFG508A29ABCDEFG413CE9FEF</string></value></member><member><name>KEY_MODE</name><value><string>LOCAL</string></value></member></struct></value></data></array></value></param></params></methodCall>
  """
  
  static let installResponse =
  """
  <?xml version="1.0" encoding="ISO-8859-1"?><methodResponse><params><param><value></value></param></params></methodResponse>
  """
  
  static let emptyResponse =
  """
  <?xml version="1.0" encoding="iso-8859-1"?>
  <methodResponse><params><param>
    <value></value>
  </param></params></methodResponse>
  """
  
  static let hmIPListDevices =
  """
  <?xml version="1.0" encoding="ISO-8859-1"?><methodCall><methodName>listDevices</methodName><params><param><value>ZeePusher</value></param></params></methodCall>
  """
  
  static let simpleNested =
  """
  <?xml version="1.0" encoding="iso-8859-1"?>
  <methodCall>
    <methodName>system.multicall</methodName>
    <params>
      <param>
        <value>
          <array>
            <data>
              <value>
                <struct>
                  <member><name>methodName</name><value>event</value></member>
                  <member><name>params</name><value>
                    <array>
                      <data>
                        <value>SeePusher</value>
                        <value>LEQ123456:0</value>
                        <value>STICKY_UNREACH</value>
                        <value><boolean>1</boolean></value>
                      </data>
                    </array>
                  </value></member>
                </struct>
              </value>
            </data>
          </array>
        </value>
      </param>
    </params>
  </methodCall>
  """

  static let multiCall =
  """
  <?xml version="1.0" encoding="iso-8859-1"?>
  <methodCall><methodName>system.multicall</methodName>
  <params><param><value><array><data><value><struct><member><name>methodName</name><value>event</value></member><member><name>params</name><value><array><data><value>SeePusher</value><value>LEQ123456:0</value><value>STICKY_UNREACH</value><value><boolean>1</boolean></value></data></array></value></member></struct></value><value><struct><member><name>methodName</name><value>event</value></member><member><name>params</name><value><array><data><value>SeePusher</value><value>LEQ123458:0</value><value>UNREACH</value><value><boolean>1</boolean></value></data></array></value></member></struct></value><value><struct><member><name>methodName</name><value>event</value></member><member><name>params</name><value><array><data><value>SeePusher</value><value>LEQ123457:0</value><value>STICKY_UNREACH</value><value><boolean>1</boolean></value></data></array></value></member></struct></value><value><struct><member><name>methodName</name><value>event</value></member><member><name>params</name><value><array><data><value>SeePusher</value><value>LEQ123459:0</value><value>UNREACH</value><value><boolean>1</boolean></value></data></array></value></member></struct></value></data></array></value></param></params></methodCall>
  """
}
