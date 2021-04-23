using UnityEngine;
using System.Collections;

public class VRButton : MonoBehaviour
{
	public string TriggerTag;
    public GameObject Receiver;
    public string MethodName;

	public void OnTriggerEnter(Collider other)
    {
    	if(other.tag==TriggerTag||TriggerTag=="")
    	{
    		Receiver.SendMessage(MethodName);
    	}
    }
}
