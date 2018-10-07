Shader "SCP/GetData"
{
    SubShader
    {
        // Draw ourselves after all opaque geometry
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry+2147481648" }
        GrabPass { "_GetData" }
    }
}