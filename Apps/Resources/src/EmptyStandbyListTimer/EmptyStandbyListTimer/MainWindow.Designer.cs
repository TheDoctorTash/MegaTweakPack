namespace EmptyStandbyListTimer
{
    partial class MainWindow
    {
        /// <summary>
        /// Variável de designer necessária.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Limpar os recursos que estão sendo usados.
        /// </summary>
        /// <param name="disposing">true se for necessário descartar os recursos gerenciados; caso contrário, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Código gerado pelo Windows Form Designer

        /// <summary>
        /// Método necessário para suporte ao Designer - não modifique 
        /// o conteúdo deste método com o editor de código.
        /// </summary>
        private void InitializeComponent()
        {
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.flowTopPanel = new System.Windows.Forms.FlowLayoutPanel();
            this.flowTopHorPanel = new System.Windows.Forms.FlowLayoutPanel();
            this.TimeIntervalLabel = new System.Windows.Forms.Label();
            this.TimeIntervalValue = new System.Windows.Forms.NumericUpDown();
            this.flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
            this.ShouldExecuteImmediatelyValue = new System.Windows.Forms.CheckBox();
            this.flowBottomPanel = new System.Windows.Forms.FlowLayoutPanel();
            this.tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel();
            this.TimerProgressBar = new System.Windows.Forms.ProgressBar();
            this.ButtonsFlowPanel = new System.Windows.Forms.FlowLayoutPanel();
            this.StartTimerBtn = new System.Windows.Forms.Button();
            this.StopTimerBtn = new System.Windows.Forms.Button();
            this.tableLayoutPanel1.SuspendLayout();
            this.flowTopPanel.SuspendLayout();
            this.flowTopHorPanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.TimeIntervalValue)).BeginInit();
            this.flowLayoutPanel1.SuspendLayout();
            this.flowBottomPanel.SuspendLayout();
            this.tableLayoutPanel2.SuspendLayout();
            this.ButtonsFlowPanel.SuspendLayout();
            this.SuspendLayout();
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.ColumnCount = 1;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel1.Controls.Add(this.flowTopPanel, 0, 0);
            this.tableLayoutPanel1.Controls.Add(this.flowBottomPanel, 0, 1);
            this.tableLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel1.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.RowCount = 2;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 69F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel1.Size = new System.Drawing.Size(550, 173);
            this.tableLayoutPanel1.TabIndex = 0;
            // 
            // flowTopPanel
            // 
            this.flowTopPanel.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.flowTopPanel.AutoSize = true;
            this.flowTopPanel.Controls.Add(this.flowTopHorPanel);
            this.flowTopPanel.Controls.Add(this.flowLayoutPanel1);
            this.flowTopPanel.FlowDirection = System.Windows.Forms.FlowDirection.TopDown;
            this.flowTopPanel.Location = new System.Drawing.Point(187, 21);
            this.flowTopPanel.Name = "flowTopPanel";
            this.flowTopPanel.Size = new System.Drawing.Size(175, 61);
            this.flowTopPanel.TabIndex = 0;
            // 
            // flowTopHorPanel
            // 
            this.flowTopHorPanel.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.flowTopHorPanel.AutoSize = true;
            this.flowTopHorPanel.Controls.Add(this.TimeIntervalLabel);
            this.flowTopHorPanel.Controls.Add(this.TimeIntervalValue);
            this.flowTopHorPanel.Location = new System.Drawing.Point(3, 3);
            this.flowTopHorPanel.Name = "flowTopHorPanel";
            this.flowTopHorPanel.Size = new System.Drawing.Size(169, 26);
            this.flowTopHorPanel.TabIndex = 2;
            // 
            // TimeIntervalLabel
            // 
            this.TimeIntervalLabel.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.TimeIntervalLabel.AutoSize = true;
            this.TimeIntervalLabel.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.TimeIntervalLabel.Location = new System.Drawing.Point(3, 6);
            this.TimeIntervalLabel.Name = "TimeIntervalLabel";
            this.TimeIntervalLabel.Size = new System.Drawing.Size(82, 13);
            this.TimeIntervalLabel.TabIndex = 0;
            this.TimeIntervalLabel.Text = "Time Interval (s)";
            this.TimeIntervalLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // TimeIntervalValue
            // 
            this.TimeIntervalValue.Location = new System.Drawing.Point(91, 3);
            this.TimeIntervalValue.Maximum = new decimal(new int[] {
            1200,
            0,
            0,
            0});
            this.TimeIntervalValue.Minimum = new decimal(new int[] {
            60,
            0,
            0,
            0});
            this.TimeIntervalValue.Name = "TimeIntervalValue";
            this.TimeIntervalValue.Size = new System.Drawing.Size(75, 20);
            this.TimeIntervalValue.TabIndex = 4;
            this.TimeIntervalValue.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.TimeIntervalValue.Value = new decimal(new int[] {
            300,
            0,
            0,
            0});
            // 
            // flowLayoutPanel1
            // 
            this.flowLayoutPanel1.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.flowLayoutPanel1.AutoSize = true;
            this.flowLayoutPanel1.Controls.Add(this.ShouldExecuteImmediatelyValue);
            this.flowLayoutPanel1.Location = new System.Drawing.Point(5, 35);
            this.flowLayoutPanel1.Name = "flowLayoutPanel1";
            this.flowLayoutPanel1.Size = new System.Drawing.Size(165, 23);
            this.flowLayoutPanel1.TabIndex = 3;
            // 
            // ShouldExecuteImmediatelyValue
            // 
            this.ShouldExecuteImmediatelyValue.AutoSize = true;
            this.ShouldExecuteImmediatelyValue.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.ShouldExecuteImmediatelyValue.Location = new System.Drawing.Point(3, 3);
            this.ShouldExecuteImmediatelyValue.Name = "ShouldExecuteImmediatelyValue";
            this.ShouldExecuteImmediatelyValue.Size = new System.Drawing.Size(159, 17);
            this.ShouldExecuteImmediatelyValue.TabIndex = 1;
            this.ShouldExecuteImmediatelyValue.Text = "Should Execute Immediately";
            this.ShouldExecuteImmediatelyValue.UseVisualStyleBackColor = true;
            // 
            // flowBottomPanel
            // 
            this.flowBottomPanel.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.flowBottomPanel.AutoSize = true;
            this.flowBottomPanel.Controls.Add(this.tableLayoutPanel2);
            this.flowBottomPanel.Location = new System.Drawing.Point(5, 107);
            this.flowBottomPanel.Name = "flowBottomPanel";
            this.flowBottomPanel.Size = new System.Drawing.Size(539, 63);
            this.flowBottomPanel.TabIndex = 1;
            // 
            // tableLayoutPanel2
            // 
            this.tableLayoutPanel2.ColumnCount = 1;
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel2.Controls.Add(this.TimerProgressBar, 0, 0);
            this.tableLayoutPanel2.Controls.Add(this.ButtonsFlowPanel, 0, 1);
            this.tableLayoutPanel2.Dock = System.Windows.Forms.DockStyle.Top;
            this.tableLayoutPanel2.Location = new System.Drawing.Point(3, 3);
            this.tableLayoutPanel2.Name = "tableLayoutPanel2";
            this.tableLayoutPanel2.RowCount = 2;
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 43.33333F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 56.66667F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel2.Size = new System.Drawing.Size(533, 60);
            this.tableLayoutPanel2.TabIndex = 0;
            // 
            // TimerProgressBar
            // 
            this.TimerProgressBar.Dock = System.Windows.Forms.DockStyle.Fill;
            this.TimerProgressBar.Location = new System.Drawing.Point(3, 3);
            this.TimerProgressBar.Name = "TimerProgressBar";
            this.TimerProgressBar.Size = new System.Drawing.Size(527, 19);
            this.TimerProgressBar.TabIndex = 0;
            // 
            // ButtonsFlowPanel
            // 
            this.ButtonsFlowPanel.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.ButtonsFlowPanel.AutoSize = true;
            this.ButtonsFlowPanel.Controls.Add(this.StartTimerBtn);
            this.ButtonsFlowPanel.Controls.Add(this.StopTimerBtn);
            this.ButtonsFlowPanel.Location = new System.Drawing.Point(185, 28);
            this.ButtonsFlowPanel.Name = "ButtonsFlowPanel";
            this.ButtonsFlowPanel.Size = new System.Drawing.Size(162, 29);
            this.ButtonsFlowPanel.TabIndex = 1;
            // 
            // StartTimerBtn
            // 
            this.StartTimerBtn.Location = new System.Drawing.Point(3, 3);
            this.StartTimerBtn.Name = "StartTimerBtn";
            this.StartTimerBtn.Size = new System.Drawing.Size(75, 23);
            this.StartTimerBtn.TabIndex = 0;
            this.StartTimerBtn.Text = "Start Timer";
            this.StartTimerBtn.UseVisualStyleBackColor = true;
            this.StartTimerBtn.Click += new System.EventHandler(this.StartTimerBtn_Click);
            // 
            // StopTimerBtn
            // 
            this.StopTimerBtn.Location = new System.Drawing.Point(84, 3);
            this.StopTimerBtn.Name = "StopTimerBtn";
            this.StopTimerBtn.Size = new System.Drawing.Size(75, 23);
            this.StopTimerBtn.TabIndex = 1;
            this.StopTimerBtn.Text = "Stop Timer";
            this.StopTimerBtn.UseVisualStyleBackColor = true;
            this.StopTimerBtn.Click += new System.EventHandler(this.StopTimerBtn_Click);
            // 
            // MainWindow
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.ClientSize = new System.Drawing.Size(550, 173);
            this.Controls.Add(this.tableLayoutPanel1);
            this.Name = "MainWindow";
            this.Text = "EmptyStandbyListTimer";
            this.tableLayoutPanel1.ResumeLayout(false);
            this.tableLayoutPanel1.PerformLayout();
            this.flowTopPanel.ResumeLayout(false);
            this.flowTopPanel.PerformLayout();
            this.flowTopHorPanel.ResumeLayout(false);
            this.flowTopHorPanel.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.TimeIntervalValue)).EndInit();
            this.flowLayoutPanel1.ResumeLayout(false);
            this.flowLayoutPanel1.PerformLayout();
            this.flowBottomPanel.ResumeLayout(false);
            this.tableLayoutPanel2.ResumeLayout(false);
            this.tableLayoutPanel2.PerformLayout();
            this.ButtonsFlowPanel.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
        private System.Windows.Forms.FlowLayoutPanel flowTopPanel;
        private System.Windows.Forms.FlowLayoutPanel flowBottomPanel;
        private System.Windows.Forms.FlowLayoutPanel flowTopHorPanel;
        private System.Windows.Forms.Label TimeIntervalLabel;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel1;
        private System.Windows.Forms.CheckBox ShouldExecuteImmediatelyValue;
        private System.Windows.Forms.NumericUpDown TimeIntervalValue;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel2;
        private System.Windows.Forms.ProgressBar TimerProgressBar;
        private System.Windows.Forms.FlowLayoutPanel ButtonsFlowPanel;
        private System.Windows.Forms.Button StartTimerBtn;
        private System.Windows.Forms.Button StopTimerBtn;
    }
}

