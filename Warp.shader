Shader "Unlit/Warp"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Zoom ("Zoom", Range(0.0000001,4)) = 1
        _Octaves ("Octaves", Range(2,16)) = 2
        _Move ("Move", Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Library\PackageCache\jp.keijiro.noiseshader@2.0.0\Shader\ClassicNoise2D.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Zoom;
            float4 _Move;

            float _Octaves;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = (v.uv - 0.5)*_Zoom + _Move.xy;
                return o;
            }

            float fbm(float2 x)
            {    
                float t = 0.0;
                for( int i = 0; i < _Octaves; i++ )
                {
                    float f = pow( 2.0, float(i) );
                    t += ClassicNoise(f*x);
                }
                return t;
            }
            float pattern(float2 x){
                // f(fbm(x) + 4*g(fbm(x) + 4*h(fbm(x))))
                float2 g = float2(fbm(x + float2(4.4, 1.6)), fbm(x + float2(7, 2.1)));
                float2 h = float2(fbm(x + 4*g + float2(1.2, 5.7)), fbm(x + 4*g + float2(3.1, 1.9)));
                
                return fbm(x + 4*h);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float waves = pattern(i.uv);
                fixed4 col = fixed4(0,0,0,1);
                col.xyz += 0.5 + 0.5*cos( _Time.x*10 + waves*0.7 + fixed3(0.1,0.4,0.8));
                return col;
            }
            ENDCG
        }
    }
}
