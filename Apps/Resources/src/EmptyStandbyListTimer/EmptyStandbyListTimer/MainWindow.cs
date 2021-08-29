using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace EmptyStandbyListTimer
{
    public partial class MainWindow : Form
    {

        private double TimeInterval { get; set; }
        private bool ShouldExecuteImmediately { get; set; }

        private static System.Timers.Timer SystemTimer { get; set; }
        private static Timer ProgressBarTimer { get; set; }
        private Process EmptyStandbyListProcess { get; set; }
        private const string EmptyStandbyListExeName = "EmptyStandbyList.exe";

        private string FilePath => AppDomain.CurrentDomain.BaseDirectory;

        public MainWindow()
        {
            this.InitializeComponent();
            this.ConfigureEmptyStandbyListProcess();
        }

        /// <summary>
        /// Starts the timer countdown.
        /// </summary>
        private void StartTimer()
        {
            this.TimeInterval = decimal.ToDouble(this.TimeIntervalValue.Value);
            this.ShouldExecuteImmediately = this.ShouldExecuteImmediatelyValue.Checked;

            if (this.ShouldExecuteImmediately)
                this.ExecuteEmptyStandbyList(null, null);

            this.StartNewTimer(this.TimeInterval);
        }

        /// <summary>
        /// Stop and reset the timer countdown.
        /// </summary>
        private void StopTimer()
        {
            SystemTimer.Stop();
            SystemTimer.Elapsed -= this.ExecuteEmptyStandbyList;

            ProgressBarTimer.Stop();
            this.TimerProgressBar.Value = 0;
        }

        #region Timer

        /// <summary>
        /// Instantiate a new System.Timers.Timer with the given time in seconds.
        /// </summary>
        /// <param name="seconds">time to countdown</param>
        private void StartNewTimer(double seconds)
        {

            #region Progress Bar
            this.TimerProgressBar.Maximum = (int)(seconds * 1000);

            ProgressBarTimer = new Timer
            {
                Interval = 1000,
                Enabled = true
            };

            ProgressBarTimer.Tick += new EventHandler(this.ProgressBarTickEvent);
            #endregion


            #region EmptyStandbyList
            SystemTimer = new System.Timers.Timer
            {
                Interval = seconds * 1000,
                Enabled = true
            };

            SystemTimer.Elapsed += this.ExecuteEmptyStandbyList;
            #endregion         
        }

        private void ProgressBarTickEvent(Object myObject, EventArgs myEventArgs)
        {
            if(this.TimerProgressBar.Value < this.TimerProgressBar.Maximum)
            {
                this.TimerProgressBar.Value += ProgressBarTimer.Interval;
            }
            else
            {
                this.TimerProgressBar.Value = 0;
            }
        }

        #endregion

        #region EmptyStandbyList Process

        /// <summary>
        /// Configure the process of the EmptyStandbyList.exe to be ready to start.
        /// </summary>
        private void ConfigureEmptyStandbyListProcess()
        {
            this.EmptyStandbyListProcess = new Process();
            EmptyStandbyListProcess.StartInfo.UseShellExecute = false;
            EmptyStandbyListProcess.StartInfo.FileName = this.FilePath + EmptyStandbyListExeName;
            EmptyStandbyListProcess.StartInfo.CreateNoWindow = true;
        }

        /// <summary>
        /// Try to execute the previously configured process of the EmptyStandbyList.exe
        /// </summary>
        private void ExecuteEmptyStandbyList(object source, System.Timers.ElapsedEventArgs e)
        {
            try
            {
                EmptyStandbyListProcess.Start();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        #endregion

        #region Forms Events
        private void StartTimerBtn_Click(object sender, EventArgs e)
        {
            this.StartTimer();
        }

        private void StopTimerBtn_Click(object sender, EventArgs e)
        {
            this.StopTimer();
        }
        #endregion
    }
}
