Shader "ViveSR/R_PortalMeshShaderMask"
{
	Properties
	{
		_StencilValue("Stencil Write Value", float) = 1
		_MainTex("Base Texture", 2D) = "white" {}
		[Toggle] _Debug("Debug", Int) = 0
		_DebugDistance("Test Distance", Range(0, 10)) = 1.5 // _DebugColor("Debug Color", Color) = (1,1,1,1)
		_MinDepth("MinDepth", Range(0, 10)) = 1.5
		_MaxDepth("MaxDepth", Range(0, 10)) = 10

		[Enum(All, 15, None, 0)] _ColorWrite("Color Write", Float) = 0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" "Queue" = "Background-2" }
			LOD 100

			Pass
			{
				Cull Off
				ZWrite On
				ColorMask Off
				Stencil{
					Ref[_StencilValue]
					Comp Always
					Pass Replace
				}

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				sampler2D _MainTex;
				float _MinDepth;
				float _MaxDepth;
				float _DebugDistance;
				bool _Debug;

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uvCoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					float2 uvCoord : TEXCOORD0;
				};

				struct fOutput
				{
					float4 color: COLOR;
				};

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uvCoord.x = v.uvCoord.x;
					o.uvCoord.y = 1 - v.uvCoord.y;
					return o;
				}

				fOutput frag(v2f i)
				{
					fOutput fOut;
					float viewD; // View distance (depth)

					if (_Debug)
					{
						clip(_DebugDistance - _MinDepth); // If _DebugDistance < _MinDepth, discard pixel
					}
					else
					{
						viewD = viewD = tex2D(_MainTex, i.uvCoord).r * 0.01; // * 0.01; // cm to m 
						clip(viewD - _MinDepth); // If viewD < _MinDepth, discard pixel
						// clip(_MaxDepth - viewD); // If viewD > _MaxDepth, discard pixel ???
					}

					fOut.color = fixed4(1.0, 1.0, 1.0, 1.0);

					return fOut;
				}
				ENDCG
			}
		}
}
