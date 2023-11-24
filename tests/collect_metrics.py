from prometheus_api_client import PrometheusConnect
from datetime import datetime
import time
import subprocess

def calc_nodes_active_time():
    prom = PrometheusConnect(url ="http://k3s.nmatheus.cloud:8080", disable_ssl=True)

    #Busca o timestamp de quando o nó foi criado
    node_created = prom.custom_query(query="kube_node_created")

    #Dia e timestamp atual
    today = datetime.now().day
    timestamp_atual = int(time.time())

    #Trata os dados e coloca no dicionário o nó como key e o como valor a quanto tempo o nó foi criado (em segundos)
    created_at_dict = {}
    for metric in node_created:
        instance = metric['metric']['node'].split(":")[0]
        timestamp = int(metric['value'][1])

        data_hora = datetime.fromtimestamp(timestamp)
        dia_do_mes = data_hora.day

        if dia_do_mes == today:
            diferenca_em_segundos = timestamp_atual - timestamp
            created_at_dict[instance] = diferenca_em_segundos

    #Busca nos eventos quando o nó foi destruido
    nodenotready_event = subprocess.check_output("sudo /usr/local/bin/kubectl --kubeconfig='/home/matheus/.kube/config.k3s' get events -o wide | grep -i NodeNotReady", shell=True)
    nodenotready_event = nodenotready_event.decode("utf-8")

    node_down_at_seconds = {}
    for saida in nodenotready_event.split("\n"):
        if (len(saida.split("node/")) > 1):
            event_time = saida.split("Normal")[0]
            node = saida.split("node/")[1].split("node-controller")[0]

            if event_time.strip()[2] == "m":
                event_time = event_time.strip().split("m")[0]
                event_time = int(event_time)*60


            if(len(node.strip())<=21):
                node_down_at_seconds[node.strip()] = event_time

    # Inicializa um novo dicionário para armazenar a diferença entre o tempo de criação e o tempo em que o alerta foi emitido
    nodes_active_seconds = {}

    # Itera sobre as chaves do segundo dicionário
    for key in node_down_at_seconds:
        # Verifica se a chave existe no primeiro dicionário
        if key in created_at_dict:
            # Calcula a diferença dos valores e armazena no novo dicionário
            if(type(node_down_at_seconds[key]) == int):
                active_seconds = created_at_dict[key] - node_down_at_seconds[key]
                nodes_active_seconds[key] = active_seconds

    #Percorre o dicionário para somar o tempo médio e total de atividade dos nós
    total_time_active_seconds = 0
    for time_used in nodes_active_seconds.values():
        total_time_active_seconds += time_used

    if(len(nodes_active_seconds) == 0):
        total_time_active_seconds = 0
        average_time_active_seconds = 0
    else:
        average_time_active_seconds = total_time_active_seconds/len(nodes_active_seconds)

    print(nodes_active_seconds)

    return average_time_active_seconds, total_time_active_seconds

tempo_medio, tempo_total = calc_nodes_active_time()
print(f"Tempo médio de atividade dos nós: {tempo_medio}")
print(f"Tempo médio de atividade dos nós: {tempo_total}")