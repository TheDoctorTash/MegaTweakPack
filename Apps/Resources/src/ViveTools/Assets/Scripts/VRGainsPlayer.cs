using UnityEngine;
using System.Collections;
using Valve.VR;

public class VRGainsPlayer : MonoBehaviour
{
    public Transform Player;
    public GainsZone Zone;


    Transform trans;
    VRRigidbodyPlayer physicsPlayer;
    SteamVR_PlayArea playArea;
    Vector3 lastPlayerPos;

    Gain gains;
    void Start()
    {
        trans = GetComponent<Transform>();
		Player=trans.Find("Camera (eye)");
        physicsPlayer = GetComponent<VRRigidbodyPlayer>();
        playArea = GetComponent<SteamVR_PlayArea>();
        gains = new Gain();
        lastPlayerPos = Player.localPosition;
    }

    void Update()
    {
        #region VRControls

        #endregion
        gains.Calc(playArea, Zone, Player);

        if (physicsPlayer!=null)
        {
            gains = physicsPlayer.FilterGains(gains);
        }
        //Debug.Log("gains: "+gains);
        Vector3 diff = Player.localPosition - lastPlayerPos;
        float xGain = diff.x < 0?gains.NegX:gains.PosX;
        float zGain = diff.z < 0?gains.NegZ:gains.PosZ;
        float finalGains = xGain > zGain ? xGain : zGain;
        Vector3 movement = diff * (finalGains - 1);
        movement.y = 0;
        trans.Translate(movement);

        lastPlayerPos = Player.localPosition;
    }
}
