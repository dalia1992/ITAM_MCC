# Código para analizar los resultados obtenidos
setwd("~/Dropbox/ITAM_MCC/Semestre_3/Operativos/proyecto/resultados4_mejor")
library(tidyverse)

Kern <- list.files(pattern = 'kern') %>% 
  lapply(read_csv) %>% 
  bind_rows%>% 
  select(-'X1') 

Dev <- list.files(pattern = 'device') %>% 
  lapply(read_csv) %>% 
  bind_rows %>% 
  select(-'X1') %>% 
  left_join(Kern)


App <- list.files(pattern = 'app') %>% 
  lapply(read_csv) %>% 
  bind_rows%>% 
  select(-'X1') %>% 
  left_join(Kern)

exps1<-unique(Dev$experiment)
exps2<- unique(App$experiment)
exps<- intersect(exps1,exps2)

Dev <- Dev %>% filter(experiment %in% exps)
length(unique(Dev$experiment))

Results<-left_join(App,Dev)

Results <- Results %>% 
  mutate("lag"=send_time-arr_time)

P_sent<-Dev %>% group_by(experiment) %>% 
  summarise('Sent'=n(), 'strategy'=unique(strategy),
            'wait'=unique(wait), 'nDevices'=unique(nDevices),
             'out_fun'=unique(out_fun),
            'max_time'=unique(max_time)) %>% 
  ungroup()
P_received<- Results %>% group_by(experiment) %>% 
  summarise('Received'=n(), 'strategy'=unique(strategy),
            'wait'=unique(wait), 'nDevices'=unique(nDevices),
            'out_fun'=unique(out_fun),
            'max_time'=unique(max_time)) %>% 
  ungroup()
IS<-P_sent %>% filter(strategy==c('hybrid')) %>% 
  filter(nDevices==3) %>% 
  filter(out_fun=='constante') %>% 
  filter(max_time==0.2*60)
IR<-P_received%>% filter(strategy=='hybrid')%>% 
  filter(nDevices==3)%>% 
  filter(out_fun=='constante') %>% 
  filter(max_time==0.2*60)

plot((IS$wait),IR$Received/IS$Sent)

########################################################3
OUT <- Dev %>% group_by(experiment) %>% 
  summarise('sent'=n(), max_time=unique(max_time), 'strategy'=unique(strategy)) %>%
  mutate('throughput_out'=sent/max_time)

IN <- App %>% group_by(experiment) %>% 
  summarise('received'=n(), max_time=12) %>%
  mutate('throughput_in'=received/max_time)

INOUT<- left_join(IN, OUT)
INOUT<- INOUT %>%  mutate('receive_rate'=received/sent) %>% mutate('package_lost'=sent-received)

pdf('~/Dropbox/ITAM_MCC/Semestre_3/Operativos/proyecto/inout.pdf')
ggplot()+theme_bw()+
  geom_point(aes(INOUT$throughput_out, INOUT$throughput_in, color=INOUT$strategy, 
                 shape=INOUT$strategy))+
  geom_line(aes(c(0,max(INOUT$throughput_out)),c(0,max(INOUT$throughput_out))))+
  xlab('Output packet rate (pkt/s)')+
  ylab('Input packet rate (pkt/s)')+
  labs(color = "Strategy", shape="Strategy")+
  ggtitle("Throughput output vs input")+
  theme(plot.title = element_text(hjust = 0.5))
dev.off()

ggplot(INOUT)+theme_bw()+
  geom_histogram(aes(receive_rate, fill=strategy))+
  facet_wrap(~strategy)+
  labs(fill = "Strategy")+
  xlab('Receive rate')+
  ylab('')

ggplot(INOUT)+
  geom_point(aes(throughput_out, receive_rate,col=strategy))+
  xlab('Throughput out')+
  ylab('Receive rate')+
  labs(fill = "Strategy")

pdf('~/Dropbox/ITAM_MCC/Semestre_3/Operativos/proyecto/packlost.pdf')
ggplot(INOUT)+theme_bw()+
  geom_point(aes(throughput_out, package_lost,col=strategy, shape=strategy))+
  xlab('Output packet rate (pkt/s)')+
  ylab('Packets lost')+
  labs(col = "Strategy", shape='Strategy')+
  ggtitle('Packets lost by output packet rate')+
  theme(plot.title = element_text(hjust = 0.5))
dev.off()

###########################################################
ggplot(Kern)+theme_bw()+
  geom_histogram(aes(count_buffer, fill=strategy))+
  facet_wrap(~strategy)+
  labs(fill = "Strategy")+
  xlab('Times Buffer was full')+
  ylab('')

pdf('~/Dropbox/ITAM_MCC/Semestre_3/Operativos/proyecto/buf_full.pdf')
ggplot()+theme_bw()+
  geom_point(aes(INOUT$throughput_out,Kern$count_buffer, col=Kern$strategy, shape=Kern$strategy))+
  labs(color = "Strategy", shape="Strategy")+
  xlab('Output packet rate (pkt/s)')+
  ylab('Buffer Full')+
  ggtitle('Times buffer was full against output packet rate (pkt/s)')+
  theme(plot.title = element_text(hjust = 0.5))
dev.off()
################################################################################
pdf('~/Dropbox/ITAM_MCC/Semestre_3/Operativos/proyecto/latency.pdf')

Results<-Results %>% mutate('latency'=arr_time-send_time)
ggplot(Results)+theme_bw()+
  geom_histogram(aes(latency, fill=strategy))+
  facet_wrap(~strategy)+
  labs(fill = "Strategy")+
  xlab('Latency')+
  ylab('')
dev.off()
################################################################################

