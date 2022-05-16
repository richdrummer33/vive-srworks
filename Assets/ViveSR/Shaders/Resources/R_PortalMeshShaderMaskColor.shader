Shader "ViveSR/R_PortalMeshShaderMaskColorKey"
{
	Properties
	{
		_StencilValue("Stencil Write Value", float) = 1
		_MainTex("Base Texture", 2D) = "white" {}
		_KeyColor("Key Color", Color) = (0,1,0)
		_Near("Near", Range(0, 2)) = 0.01
		[Toggle] _Debug("Debug", Int) = 0
		_DebugDistance("Test Distance", float) = 0 // _DebugColor("Debug Color", Color) = (1,1,1,1)

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
				float4 _KeyColor;
				float _Near;

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
					float r,g,b; // View distance (depth)

					fOut.color = fixed4(1.0, 1.0, 1.0, 1.0);

					if (_Debug)
					{
						clip(_DebugDistance - _MinDepth); // If _DebugDistance < _MinDepth, discard pixel
					}
					else
					{//
						//r = tex2D(_MainTex, i.uvCoord).r; // * 0.01; // cm to m 
						//g = tex2D(_MainTex, i.uvCoord).g; // * 0.01; // cm to m 
						//b = tex2D(_MainTex, i.uvCoord).b; // * 0.01; // cm to m 

						fixed4 c1 = tex2D(_MainTex, i.uvCoord);
						//
						clip(_Near - distance(_KeyColor, c1));

						//if (r < _Key.r && g > _Key.g && b < _Key.b) // very green, clip to see cam feed
						//{
						//	clip(-1); // If the color is more green than the key, cut it out
						//}
						/*if (green < _Key)
						{
							fOut.color = fixed4(0, 0, 0, 0);
						}*/

						//viewD = viewD = tex2D(_MainTex, i.uvCoord).r * 0.01; // * 0.01; // cm to m 
						//clip(viewD - _MinDepth); // If viewD < _MinDepth, discard pixel
						// clip(_MaxDepth - viewD); // If viewD > _MaxDepth, discard pixel ???
					}


					return fOut;
				}
				ENDCG
			}
		}
}
