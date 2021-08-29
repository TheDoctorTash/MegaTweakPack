using System;
using System.Collections.Generic;
using UnityEngine;
using Valve.VR;

public class Gain
{
    public enum Direction
    {
        PosX,
        NegX,
        PosZ,
        NegZ
    }

    public static float NormalMax = 1.5f;
    public static float FringeMax = 2f;
    public static float Min = 0.5f;

    public float PosX { get; set; }
    public float NegX { get; set; }
    public float PosZ { get; set; }
    public float NegZ { get; set; }

    public Gain():this(1,1,1,1)
    {
    }
    public Gain(float posX, float negX, float posZ, float negZ)
    {
        PosX = posX;
        NegX = negX;
        PosZ = posZ;
        NegZ = negZ;
    }

    public override string ToString ()
	{
		return string.Format ("[Gain: PosX={0}, NegX={1}, PosZ={2}, NegZ={3}]", PosX, NegX, PosZ, NegZ);
	}

    public void Calc(SteamVR_PlayArea playArea, GainsZone gainsZone, Transform player)
    {
        if (gainsZone == null)
        {
            PosX = 1;
            NegX = 1;
            PosZ = 1;
            NegZ = 1;
            return;
        }

        pointToPoint(playArea, gainsZone, player);

        if (PosX>NormalMax|| PosX < 0)
        {
            pointToEdge(playArea, gainsZone, player, Direction.PosX);
            if (PosX<NormalMax)
            {
                PosX = NormalMax;
            }
        }
        if (NegX > NormalMax || NegX < 0)
        {
            pointToEdge(playArea, gainsZone, player, Direction.NegX);
            if (NegX < NormalMax)
            {
                NegX = NormalMax;
            }
        }
        if (PosZ > NormalMax || PosZ < 0)
        {
            pointToEdge(playArea, gainsZone, player, Direction.PosZ);
            if (PosZ < NormalMax)
            {
                PosZ = NormalMax;
            }
        }
        if (NegZ > NormalMax || NegZ < 0)
        {
            pointToEdge(playArea, gainsZone, player, Direction.NegZ);
            if (NegZ < NormalMax)
            {
                NegZ = NormalMax;
            }
        }
    }

    void pointToPoint(SteamVR_PlayArea playArea, GainsZone gainsZone, Transform player)
    {
        pointToPoint(playArea, gainsZone, player, Direction.PosX);
        pointToPoint(playArea, gainsZone, player, Direction.NegX);
        pointToPoint(playArea, gainsZone, player, Direction.PosZ);
        pointToPoint(playArea, gainsZone, player, Direction.NegZ);
    }

    void pointToPoint(SteamVR_PlayArea playArea, GainsZone gainsZone, Transform player, Direction direction)
    {
        switch (direction)
        {
            case Direction.PosX:
                float posXVirtual = (gainsZone.Trans.position.x - player.position.x) + gainsZone.Size.x / 2;
                float posXReal = gainsZone.Size.x / 2 - player.localPosition.x;
                PosX = posXVirtual / posXReal;
                break;
            case Direction.NegX:
                float negXVirtual = (gainsZone.Trans.position.x - player.position.x) * -1 + gainsZone.Size.x / 2;
                float negXReal = gainsZone.Size.x / 2 + player.localPosition.x;
                NegX = negXVirtual / negXReal;
                break;
            case Direction.PosZ:
                float posZVirtual = (gainsZone.Trans.position.z - player.position.z) + gainsZone.Size.z / 2;
                float posZReal = gainsZone.Size.z / 2 - player.localPosition.z;
                PosZ = posZVirtual / posZReal;
                break;
            case Direction.NegZ:
                float negZVirtual = (gainsZone.Trans.position.z - player.position.z) * -1 + gainsZone.Size.z / 2;
                float negZReal = gainsZone.Size.z / 2 + player.localPosition.z;
                NegZ = negZVirtual / negZReal;
                break;
            default:
                break;
        }
    }

    void pointToEdge(SteamVR_PlayArea playArea, GainsZone gainsZone, Transform player)
    {
        pointToEdge(playArea, gainsZone, player, Direction.PosX);
        pointToEdge(playArea, gainsZone, player, Direction.NegX);
        pointToEdge(playArea, gainsZone, player, Direction.PosZ);
        pointToEdge(playArea, gainsZone, player, Direction.NegZ);
    }

    void pointToEdge(SteamVR_PlayArea playArea, GainsZone gainsZone, Transform player, Direction direction)
    {
        HmdQuad_t rect = new HmdQuad_t();
        SteamVR_PlayArea.GetBounds(playArea.size, ref rect);
        float width = Mathf.Abs(rect.vCorners0.v0 - rect.vCorners2.v0);
        float length = Mathf.Abs(rect.vCorners0.v2 - rect.vCorners2.v2);
        switch (direction)
        {
            case Direction.PosX:
                float posXVirtual = (gainsZone.Trans.position.x - player.position.x) + gainsZone.Size.x / 2;
                float posXReal = width / 2 - player.localPosition.x;
                PosX = posXVirtual / posXReal;
                break;
            case Direction.NegX:
                float negXVirtual = (gainsZone.Trans.position.x - player.position.x) * -1 + gainsZone.Size.x / 2;
                float negXReal = width / 2 + player.localPosition.x;
                NegX = negXVirtual / negXReal;
                break;
            case Direction.PosZ:
                float posZVirtual = (gainsZone.Trans.position.z - player.position.z) + gainsZone.Size.z / 2;
                float posZReal = length / 2 - player.localPosition.z;
                PosZ = posZVirtual / posZReal;
                break;
            case Direction.NegZ:
                float negZVirtual = (gainsZone.Trans.position.z - player.position.z) * -1 + gainsZone.Size.z / 2;
                float negZReal = length / 2 + player.localPosition.z;
                NegZ = negZVirtual / negZReal;
                break;
            default:
                break;
        }
    }
}
