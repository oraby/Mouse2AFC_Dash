# -*- coding: utf-8 -*-

import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output, State
from dash.exceptions import PreventUpdate
import datetime as dt
import pandas as pd
import analysis
# import mat_reader

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']
analysis.Plotter.setPlotType(is_mpl=False)
DATA_FILE=r"C:\Users\lisak\Documents\MA_MindBrain\LabRotations\LarkumLab\Data\all_animals_2020_03_31.pkl"
#df = mat_reader.loadFiles(DATA_FILE)
df = pd.read_pickle(DATA_FILE)
mice_names=df.Name.unique()

#%% App layout
app = dash.Dash(__name__, external_stylesheets=external_stylesheets)
app.layout = html.Div([
    html.Div([
        html.Div([
            html.Label('Mouse ID', htmlFor='mouse-drop'),
            dcc.Dropdown(
                id='mouse-drop',
                options=[{'label': i, 'value': i} for i in mice_names],
                value=None
                )
            ]),
        html.Div([
            html.Label('To select 1 day, pick only start date.',
                       htmlFor='calendar'),
            dcc.DatePickerRange(
                id='calendar',
                day_size= 29
                ),
            dcc.Checklist(
                id='date-checkbox',
                options=[{'label': 'Pick all dates', 'value': 'pick-all'}],
                value=[]
                )
            ]),
        html.Div([
            html.Button(
                id='submit-button',
                n_clicks=0,
                children='Plot'
                ),
            ])
        ],
        className='sidenav'
        ),
    html.Div([
        html.Div([
            dcc.Graph(
                id='graph1',
                style={'width': '50%',
                       'height': '90vh',
                       'display': 'inline-block'}
                ),
            dcc.Graph(
                id='graph2',
                style={'width': '50%',
                       'height': '90vh',
                       'float': 'right',
                       'display': 'inline-block'}
                )
            ]),
        html.Div([
            dcc.Graph(id='graph3', style={'height': '90vh'}),
            dcc.Graph(id='graph4', style={'height': '90vh'})
            ]),
    ],
    className='main'
    )
])

#%% Callback functions
@app.callback(
    [Output('calendar', 'min_date_allowed'),
     Output('calendar', 'max_date_allowed'),
     Output('date-checkbox', 'value')],
    [Input('mouse-drop', 'value')])

def updateCalendar(mouse_name):
  '''
  This function is called when the value of the mouse-drop changes.
  If a mouse is selected, selectable dates in the calendar are adjusted to
   the dates available in the dataset for this mouse.
  If no mouse is selected, selectable dates are adjusted to the date range
   of the entire dataset.
  The pick-all-dates checkbox is unticked.
  '''
  if mouse_name is None:
    first_date = df.Date.min()
    # Date passed to max_date_allowed is NOT allowed, only date before
    # Is this a bug?
    # We have to add another day to the last date to circumvent this.
    last_date = df.Date.max() + dt.timedelta(days=1)
  else:
    dff = df[df.Name == mouse_name]
    first_date = dff.Date.min()
    last_date = dff.Date.max() + dt.timedelta(days=1)
  checkbox_val = []
  return first_date, last_date, checkbox_val

@app.callback(
    [Output('calendar', 'start_date'),
     Output('calendar', 'end_date')],
    [Input('date-checkbox', 'value')],
    [State('calendar', 'min_date_allowed'),
     State('calendar', 'max_date_allowed')])

def pickAllDates(checkbox_val, first_date, last_date):
  '''
  This function is called when the value of the pick-all-dates checkbox is
   changed.
  If it turns from unchecked to checked, all selectable dates for his mouse
   are selected.
  If it turns from checked to unchecked, any selections are deleted.
  '''
  if len(checkbox_val):
    start_date = first_date
    # DatePickerRange uses dates in string format.
    # We need to convert to date format if we want to add a day.
    end_date = (dt.datetime.strptime(last_date, '%Y-%m-%d')).date()
    # For end_date, there is no such problem as with max_date_allowed.
    # The date of end_date is the last selected date.
    # So, we need to subtract one day from max_date_allowed (last_date) again
    #  to get the correct date for the last date that should be selected
    end_date = end_date + dt.timedelta(days=-1)
  else:
    start_date = None
    end_date = None
  return start_date, end_date

@app.callback(
  [Output('graph1', 'figure'),
   Output('graph2', 'figure'),
   Output('graph2', 'style'),
   Output('graph3', 'figure'),
   Output('graph4', 'figure')],
  [Input('submit-button', 'n_clicks')],
  [State('mouse-drop', 'value'),
   State('calendar', 'start_date'),
   State('calendar', 'end_date')])

def update_graph(clicks, mouse_name, start, end):
  '''
  This function is called when the submit button is clicked.
  If a mouse is selected and at least one date is selected, all graphs are
   updated.
  If no mouse selected or no date is picked, no update is done.
  '''
  if mouse_name is None or (start is None and end is None):
    raise PreventUpdate
  start_date = (dt.datetime.strptime(start, '%Y-%m-%d')).date()
  if end is not None:
    end_date = (dt.datetime.strptime(end, '%Y-%m-%d')).date()
    if start_date > end_date:
      raise PreventUpdate
  else:
    end_date = start_date
  # Would be good to be able to use the sub-df from updateCalendar()
  # Possibilities: https://dash.plotly.com/sharing-data-between-callbacks
  # Hidden div didn't work, json conversion didn't work
  mouse_dff = df[df.Name == mouse_name]
  time_mask = (mouse_dff.Date >= start_date) & (mouse_dff.Date <= end_date)
  time_dff = mouse_dff.loc[time_mask]
  if not len(time_dff):
    raise PreventUpdate
  # SessionNum starts at 1 every day
  single_session = True if start_date == end_date and \
   len(time_dff.SessionNum.unique()) == 1 else False

  psych_plotter = analysis.Plotter()
  analysis.psychAxes(animal_name=mouse_name, plotter=psych_plotter)
  analysis.psychAnimalSessions(time_dff, mouse_name, psych_plotter,
                               analysis.METHOD)

  trial_plotter = analysis.Plotter()
  if 'TrialStartTimestamp' in time_dff.columns:
    trial_plotter = analysis.Plotter()
    analysis.trialRate(time_dff, trial_plotter)
    show2 = {'display':'inline-block'}
  else:
    show2 = {'display':'none'}

  Plot = analysis.PerfPlots
  perf_plotter1 = analysis.Plotter()
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

  perf_plotter2 = analysis.Plotter()
  analysis.performanceOverTime(time_dff, single_session=single_session,
                               plotter=perf_plotter2,
                                draw_plots=[Plot.Performance,
                                            Plot.Difficulties,
                                            Plot.SamplingT,
                                            Plot.CatchWT,
                                            Plot.MaxFeedbackDelay])

  return psych_plotter.graph_obj, trial_plotter.graph_obj, show2, \
perf_plotter1.graph_obj, perf_plotter2.graph_obj


if __name__ == '__main__':
  app.run_server(debug=True)