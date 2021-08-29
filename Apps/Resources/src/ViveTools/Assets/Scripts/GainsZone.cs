using UnityEngine;
using System.Collections;

public class GainsZone : MonoBehaviour
{
    public Vector3 Size
    {
        get
        {
            return Trans.lossyScale;
        }
    }


    public Transform Trans;
    void Start()
    {
        Trans = GetComponent<Transform>();
    }

    public void OnTriggerEnter(Collider other)
    {
		VRGainsPlayer player = other.GetComponent<Transform>().parent.GetComponent<VRGainsPlayer>();
        if (player != null)
        {
            player.Zone = this;
        }
    }
    
    public void OnTriggerExit(Collider other)
    {
        VRGainsPlayer player = other.GetComponent<Transform>().parent.GetComponent<VRGainsPlayer>();
        if (player != null)
        {
            player.Zone = null;
        }
    }
}
