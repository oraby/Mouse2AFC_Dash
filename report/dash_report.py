# -*- coding: utf-8 -*-
"""
Created on Tue Feb  4 14:03:30 2020

@author: lisak
"""

import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output, State
from dash.exceptions import PreventUpdate

import datetime as dt
import pandas as pd

import analysis

from plotly.subplots import make_subplots
#import mat_reader

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']
analysis.Plotter.setPlotType(is_mpl=False)
analysis.setMatplotlibParams(silent=True) 


#DATA_FILE=r"C:\Users\lisak\Documents\MA_MindBrain\LabRotations\LarkumLab\Data\wfThy2_Mouse2AFC_Dec13_2019_Session1.mat"
#df = mat_reader.loadFiles(DATA_FILE)

#df = pd.read_pickle(r"C:\Users\lisak\Documents\MA_MindBrain\LabRotations\LarkumLab\Data\Mouse2AFC_2019_12_05_to_2019_12_05.dump")
#df = pd.read_pickle(r"C:\Users\lisak\Documents\MA_MindBrain\LabRotations\LarkumLab\Data\WT4_2018_12_27_to_2019_10_23.dump")
#df = pd.read_pickle(r"C:\Users\lisak\Documents\MA_MindBrain\LabRotations\LarkumLab\Data\all_animals_2020_03_03.pkl")
df = pd.read_pickle(r"C:\Users\lisak\Documents\MA_MindBrain\LabRotations\LarkumLab\Data\all_animals_2020_03_31.pkl")

mice_names=df.Name.unique()

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

app.layout = html.Div([
    html.Div([
        html.Div([
            html.Label('Mouse ID'),
            dcc.Dropdown(
                id = 'mouse-drop',
                options = [{'label': i, 'value': i} for i in mice_names],
                value = None
                )
            ]),
            
        html.Div([
            html.Label('To select 1 day, pick only start date.'),
            dcc.DatePickerRange(id = 'calendar',
                                day_size = 29),
            dcc.Checklist(
                id = 'date-checkbox',
                options = [{'label':'Pick all dates', 'value':'pick-all'}],
                value = []
                )
            ]),

        html.Div([
            html.Button(id='submit-button', n_clicks=0, children='Plot')
            ])
],
        className='sidenav'
        ),
        
    html.Div([        
        html.Div([
            dcc.Graph(
                id='graph1',
                style={'width': '50%', 'display': 'inline-block'}
                ),
                  
            dcc.Graph(
                id='graph2',
                style={'width': '50%', 'float': 'right', 'display': 'inline-block'}
                )
            ]),
        
        html.Div([       
            dcc.Graph(id='graph3'),
                 
            dcc.Graph(id='graph4')
            ]),
      
        # hidden div to store sub-df as json?  
        html.Div(id='hidden-div', style={'display': 'none'})
    ],
    className='main'
    )])
'''
dcc.Slider(
        id='session-slider',
        min=1,
        max=1,
        value=1,
        marks={1:"{}_{}".format(session_date, session_num)
               for (session_date, session_num), session_df in sessions},
        step=None
        )
'''

'''
@app.callback(
    Output('hidden-div', 'children'),
    [Input('mouse-drop', 'value')])

def createDfSub(mouse_name):
  if mouse_name is None:
      raise PreventUpdate
     
  dff = df[df.Name == mouse_name]
  return dff.to_json()
'''

@app.callback(
    [#Output('calendar', 'start_date'),
     #Output('calendar', 'end_date'),
     Output('calendar', 'min_date_allowed'),
     Output('calendar', 'max_date_allowed'),
     #Output('calendar', 'initial_visible_month')
     ],
    [Input('mouse-drop', 'value')])

def updateCalendar(mouse_name):
  if mouse_name is None:
    first_date = df.Date.min()
    last_date = df.Date.max() + dt.timedelta(days=1)
    # bug? max_date not allowed in calendar, only date before.
  
  else:
    #dff = pd.read_json(mouse_dff)
    dff = df[df.Name == mouse_name]
    first_date = dff.Date.min()
    last_date = dff.Date.max() + dt.timedelta(days=1)
    

    
  return first_date, last_date#, start_date
  
@app.callback(
    [Output('calendar', 'start_date'),
     Output('calendar', 'end_date')],
    [Input('date-checkbox', 'value')],
    [State('calendar', 'min_date_allowed'),
     State('calendar', 'max_date_allowed')])

def pickAllDates(checkbox_val, first_date, last_date):
  if len(checkbox_val):
    start_date = first_date
    end_date = dt.datetime.strptime(last_date, '%Y-%m-%d')
    end_date = end_date.date()
    end_date = end_date + dt.timedelta(days=-1)
    
  else:
    start_date = None
    end_date = None
    
  return start_date, end_date

@app.callback(
  [Output('graph1', 'figure'),
   #Output('graph1', 'style'),
   Output('graph2', 'figure'),
   Output('graph2', 'style'),
   Output('graph3', 'figure'),
   Output('graph4', 'figure')
   #Output('mylabel', 'children')
   ],
  [Input('submit-button', 'n_clicks')],
  [#State('hidden-div', 'children'),
   State('mouse-drop', 'value'),
   State('calendar', 'start_date'),
   State('calendar', 'end_date')])

def update_graph(clicks, mouse_name, start, end): # var 1: Input val 1; var2: Input val 2
  if mouse_name is None:
    raise PreventUpdate
    # Print error message
  if start is None and end is None:
    raise PreventUpdate
   
  start_date = dt.datetime.strptime(start, '%Y-%m-%d')
  start_date = start_date.date()
  
  if end is not None:
    end_date = dt.datetime.strptime(end, '%Y-%m-%d')
    end_date = end_date.date()
  else:
    end_date = start_date
    
  if start_date > end_date:
    raise PreventUpdate
    # Print error message
       
  mouse_dff = df[df.Name == mouse_name]
  time_mask = (mouse_dff.Date >= start_date) & (mouse_dff.Date <= end_date)
  time_dff = mouse_dff.loc[time_mask]
  
  if start_date == end_date:
    if len(time_dff.SessionNum.unique()) == 1:
      single_session = True
  else:
    single_session = False
    
  psych_plotter = analysis.Plotter()
  analysis.psychAxes(animal_name=mouse_name, plotter=psych_plotter)
  analysis.psychAnimalSessions(time_dff, mouse_name, psych_plotter, analysis.METHOD)
    
  trial_plotter = analysis.Plotter()
  if 'TrialStartTimestamp' in time_dff.columns:
    trial_plotter = analysis.Plotter()
    analysis.trialRate(time_dff, trial_plotter)
    show2 = {'display':'inline-block'}
  else: 
    show2 = {'display':'none'}
  
  
  Plot = analysis.PerfPlots  
  perf_plotter1 = analysis.Plotter(graph_obj=make_subplots(specs=[[{"secondary_y": True}]]),
                                   second_y=True)
  analysis.performanceOverTime(time_dff, single_session=single_session,
                               plotter=perf_plotter1,
                               draw_plots=[Plot.Performance,
                                           Plot.DifficultiesCount,
                                           Plot.Bias,
                                           Plot.EarlyWD,
                                           Plot.MovementT,
                                           Plot.ReactionT,
                                           Plot.StimAPO
                                           ])
                                           

  perf_plotter2 = analysis.Plotter(graph_obj=make_subplots(specs=[[{"secondary_y": True}]]),
                                   second_y=True)
  analysis.performanceOverTime(time_dff, single_session=single_session, 
                               plotter=perf_plotter2,
                                draw_plots=[Plot.Performance,
                                            Plot.Difficulties,
                                            Plot.SamplingT,
                                            Plot.CatchWT,
                                            Plot.MaxFeedbackDelay])

  
  return psych_plotter.graphly, trial_plotter.graphly, show2, \
perf_plotter1.graphly, perf_plotter2.graphly


if __name__ == '__main__':
    app.run_server(debug=True)

#%%
'''
sessions = df.groupby([df.Date,df.SessionNum])
earliest_session = df[df.Date == df.Date.min()]
earliest_session = earliest_session[earliest_session.SessionNum ==
                                earliest_session.SessionNum.min()]
earliest_session = "{}_{}".format(earliest_session.Date.iloc[0],
                              earliest_session.SessionNum.iloc[0])
latest_session = df[df.Date == df.Date.max()]
latest_session = latest_session[latest_session.SessionNum ==
                                latest_session.SessionNum.max()]
latest_session = "{}_{}".format(latest_session.Date.iloc[0],
                                latest_session.SessionNum.iloc[0])
'''