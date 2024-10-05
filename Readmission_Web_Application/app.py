from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px
import plotly.graph_objs as go
import plotly.subplots as ps
from faicons import icon_svg
from shinywidgets import render_plotly
from shiny import reactive
from shiny.express import input, render, ui

# ---------------------------------------------------------------------
# Reading in Files
# ---------------------------------------------------------------------

df = pd.read_csv(Path(__file__).parent / "hospital_admission_data_cleaned.csv")
df_filtered = df.copy()


# --------------------------------------------------------------------
# Filter Function
# -------------------------------------------------------------------

@reactive.Calc
def filtered_data():
    selected_genders = input.gender_filter()
    return df_filtered[df_filtered['gender'].isin(selected_genders)]


# --------------------------------------------------------------------
# UI configuration
# -------------------------------------------------------------------

# Title

ui.page_opts(title= "Hospital Readmission App")

# Sidebar

with ui.sidebar(position="right", open="open", title="Filter"):
    
    # Gender Filter Checkbox
    ui.input_checkbox_group("gender_filter", "Select Gender(s):", choices=["Male", "Female","not disclosed"], selected=["Male", "Female", "not disclosed"])
    

    
# ---------------------------------------------------------------------
# Visualizations
# ---------------------------------------------------------------------

# Age Readmitted plot
with ui.navset_card_tab(id="tab",title="Dashboard"):
     with ui.nav_panel("Plot",icon= icon_svg('chart-line')):
        with ui.layout_columns(fill=True, col_widths=[4, 4, 4, 6, 6, 6, 6, 12]):
            with ui.value_box(showcase=icon_svg("user")):
                "Total Patient Recorded"
                @render.express
                def total_patient_count():
                    filtered_data().shape[0]

            with ui.value_box(showcase=icon_svg("bed-pulse")):
                "Average Stay Duration"
                @render.express
                def average_stay_duration():
                    d = filtered_data()
                    if d.shape[0] > 0:
                        avg_sty = d.time_in_hospital.mean()
                        f"{avg_sty:.3} days"

            with ui.value_box(showcase=icon_svg("clock-rotate-left")):
                "Total Readmission"
                @render.express
                def total_patients_count():
                    r = filtered_data()
                    if r.shape[0]>0:
                        readmitted_sum = r[r['readmitted'] == 1]['readmitted'].sum()  # Filter and sum 'Readmitted'
                        f"{int(readmitted_sum)}"
            
            with ui.card(full_screen=True):
                 with ui.card_header():
                    "Distribution of Age vs Total Readmissions"
                    @render_plotly
                    def age_readmitted():
                        df_staged = filtered_data()
                        age_readmitted_fig = df_staged.groupby('age')['readmitted'].sum().reset_index()

                        age_readmitted_fig = px.bar(age_readmitted_fig, 
                                                x='age',
                                                y= 'readmitted',
                                                hover_data=['age', 'readmitted'],
                                                text_auto = True,
                                                height= 500,
                                                width= 650,
                                                color='readmitted')
                        age_readmitted_fig.update_xaxes(title = 'Age Group')
                        # age_readmitted_fig.update_layout(title = '',
                        #                                 title_font_size=16,
                        #                                 margin=dict(t=100)
                        #                                 )
                        
                        return age_readmitted_fig
                    

#         # Race plot:
            with ui.card(full_screen=True):
                        with ui.card_header():
                            "Race vs Total Readmissions"    
                            @render_plotly
                            def race():
                                df_staged = filtered_data()
                                race_readmitted = df_staged.groupby(['race','gender'])['readmitted'].sum().reset_index()
                                race_readmitted = race_readmitted.sort_values(by=['readmitted'], ascending=False)
                                race_readmitted_fig = px.bar(race_readmitted, x='race', y= 'readmitted', color='gender', 
                                                             hover_data=['race', 'readmitted'], text_auto = True,
                                                             height= 500, width= 650)
                                race_readmitted_fig.update_layout(legend=dict(orientation="h",yanchor="bottom",y=-0.3,xanchor="right",x=1.2))
                                return race_readmitted_fig

                # # -------------------------------------------------------------------------------------------------------------------        

#         # Staying Duration Plot:
            with ui.card(full_screen=True):
                with ui.card_header():
                    "Longest and Shortest Hospital Stays by Medical Speciality"
                    @render_plotly
                    def stay_duration():
                        df_staged = filtered_data()
                        stays_speciality = df_staged.groupby(['medical_specialty'])['time_in_hospital'].mean().round(decimals = 3).reset_index().sort_values(by = ['time_in_hospital'], ascending = False)

                        longest_stays_speciality = stays_speciality.head(5)
                        least_stays_speciality = stays_speciality.tail(5)

                        fig_Longest_stay = px.bar(longest_stays_speciality.sort_values('time_in_hospital', ascending = True), 
                                                x='time_in_hospital', y = 'medical_specialty', color = 'time_in_hospital', text_auto ='.2s')

                        fig_least_stay =  px.bar(least_stays_speciality.sort_values('time_in_hospital', ascending = True),
                                                x='time_in_hospital', y = 'medical_specialty', color = 'time_in_hospital', text_auto = '.2s')

                        

                        # creating Subplots:
                        fig_stays_ps = ps.make_subplots(rows=2, cols=1, shared_yaxes = False)

                        # Add first line plot to the subplots
                        for trace in fig_Longest_stay['data']:
                            fig_stays_ps.add_trace(trace, row=1, col=1)

                        # Add second line plot to the subplots
                        for trace in fig_least_stay['data']:
                            fig_stays_ps.add_trace(trace, row=2, col=1)

                        # Update layout
                        fig_stays_ps.update_layout(height=500, width= 650, showlegend=True)
                        fig_stays_ps.update_traces(textfont_size=10, textangle=0, textposition="inside", cliponaxis=True)
                        fig_stays_ps.update_xaxes(title_text = 'Days in Hospital',row=1, col=1)
                        fig_stays_ps.update_xaxes(title_text = 'Days in Hospital',row=2, col=1)
                        fig_stays_ps.update_yaxes(title_text = 'Medical Speciality',row=1, col=1)
                        fig_stays_ps.update_yaxes(title_text = 'Medical Speciality',row=2, col=1)

                        return fig_stays_ps
                    
# # ----------------------------------------------------------------------------------------------------------------------

        #         # Diabetes plot:
            with ui.card(full_screen=True):
                        with ui.card_header():
                            "Proportion of Diabetic Patient with change in Medication"    
                            @render_plotly
                            def diabetes():
                                df_staged = filtered_data()
                                diab_readmitted = df_staged.groupby(['diabetesMed'])['readmitted'].count().round(decimals=3).reset_index().sort_values(by=['diabetesMed'])
                                diab_change_readmitted = df_staged.groupby(['change'])['readmitted'].count().round(decimals=3).reset_index().sort_values(by=['change'])


                                # Create subplot figure
                                pie_fig = ps.make_subplots(rows=1,cols=2, subplot_titles= ("Diabetes Patient", "Change in Meds"),specs=[[{'type': 'pie'}, {'type': 'pie'}]])

                                # Pie chart 1
                                pie_fig.add_trace(go.Pie(
                                    labels=diab_readmitted['diabetesMed'],
                                    values=diab_readmitted['readmitted'],
                                    hole=0.5,  # This makes it a donut chart
                                    marker=dict(colors=['#ff9945', '#66c3ff']),
                                    textinfo='label+percent',
                                    insidetextorientation='radial',
                                    textfont=dict(size=12, color='black')
                                ), row=1, col=1)

                                # Pie chart 2
                                pie_fig.add_trace(go.Pie(
                                    labels=diab_change_readmitted['change'],
                                    values=diab_change_readmitted['readmitted'],
                                    hole=0.5,  # This makes it a donut chart
                                    marker=dict(colors=['#ff9945', '#66c3ff']),
                                    textinfo='label+percent',
                                    insidetextorientation='radial',
                                    textfont=dict(size=12, color='black')
                                ), row=1, col=2)

                                # Update layout with bold titles
                                pie_fig.update_layout(width=650, height=500, showlegend=True,margin =dict(t=100),legend=dict(orientation="h",yanchor="bottom",y=-0.3,xanchor="right",x=1.2))
                                
                                # Show the plot
                                return pie_fig

# # -------------------------------------------------------------------------------------------------------------------


        #         # Race Readmitted plot:
            with ui.card(full_screen=True):
                 with ui.card_header():
                    "Readmission Vs. Procedures, Lab Procedures, Diagnoses and Medications" 
                    @render_plotly
                    def race_readmitted():
                        df_staged = filtered_data()
                        readmitted_proced = df_staged.groupby(['num_procedures'])['readmitted'].count().reset_index().sort_values(by = ['num_procedures'] )

                        readmitted_lab_proced = df_staged.groupby(['num_lab_procedures'])['readmitted'].count().reset_index().sort_values(by = ['num_lab_procedures'] )

                        readmitted_diag = df_staged.groupby(['number_diagnoses'])['readmitted'].count().reset_index().sort_values(by = ['number_diagnoses'] )

                        readmitted_med = df_staged.groupby(['num_medications'])['readmitted'].count().reset_index().sort_values(by = ['num_medications'] )


                        # Create the first line plot
                        fig_procedures = px.line(readmitted_proced, x='num_procedures', y='readmitted', title="Number of Procedures vs Readmitted")

                        # Create the second line plot
                        fig_diagnoses = px.line(readmitted_diag, x='number_diagnoses', y='readmitted', title="Number of Diagnoses vs Readmitted")

                        # Create the third line plot 

                        fig_medications = px.line(readmitted_med, x='num_medications', y='readmitted', title="Number of medications vs Readmitted")

                        # Create the Fourth plot

                        fig_lab_procedures = px.line(readmitted_lab_proced, x='num_lab_procedures', y='readmitted', title="Number of Lab Procedures vs Readmitted")


                        # Create subplots
                        line_fig = ps.make_subplots(rows=4, cols=1, shared_yaxes = False)

                        # Add first line plot to the subplots
                        for trace in fig_procedures['data']:
                            line_fig.add_trace(trace, row=1, col=1)

                        # Add second line plot to the subplots
                        for trace in fig_diagnoses['data']:
                            line_fig.add_trace(trace, row=2, col=1)
                            
                        # Add third line plot to the subplots
                        for trace in fig_medications['data']:
                            line_fig.add_trace(trace, row=3, col=1)

                        for trace in fig_lab_procedures['data']:
                            line_fig.add_trace(trace, row=4, col=1)

                        # Update layout
                        line_fig.update_layout(height=700, width= 1300, showlegend=True)
                        line_fig.update_traces(line=dict(color='red', width=3, dash='dash'),row=1, col=1)
                        line_fig.update_traces(line=dict(color='blue', width=3, dash='dash'),row=2, col=1)
                        line_fig.update_traces(line=dict(color='green', width=3, dash='dash'),row=3, col=1)
                        line_fig.update_traces(line=dict(color='black', width=3, dash='dash'),row=4, col=1)
                        line_fig.update_xaxes(title_text = 'Number of Procedures',row=1, col=1)
                        line_fig.update_xaxes(title_text = 'Number of Diagnoses',row=2, col=1)
                        line_fig.update_xaxes(title_text = 'Number of Medications',row=3, col=1)
                        line_fig.update_xaxes(title_text = 'Number of Lab Procedures',row=4, col=1)
                        line_fig.update_yaxes(title_text = 'readmitted',row=1, col=1)
                        line_fig.update_yaxes(title_text = 'readmitted',row=2, col=1)
                        line_fig.update_yaxes(title_text = 'readmitted',row=3, col=1)
                        line_fig.update_yaxes(title_text = 'readmitted',row=4, col=1)


                        # Show plot
                        return line_fig

#   # -----------------------------------------------------------------------------------------


# Data Frame:

     with ui.nav_panel("Table",icon=icon_svg("table")):
#with ui.nav_panel("Table", icon = icon_svg("table")):
        with ui.layout_columns(col_widths=[12]):
            with ui.card(full_screen=True):
                ui.card_header("Data Cleaned")
                @render.data_frame
                def df_staged_dataframe():
                    df_staged = filtered_data()
                    return render.DataGrid(df_staged)

# # ---------------------------------------------------------------------------------------------------------------
