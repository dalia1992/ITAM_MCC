/*
 * cache.c
 */


#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "cache.h"
#include "main.h"

// Variables globales sòlo para este archivo

/* cache configuration parameters */
static int cache_split = 0;
static int cache_usize = DEFAULT_CACHE_SIZE; // Cache Unificado
static int cache_isize = DEFAULT_CACHE_SIZE; // Cache de Instrucciones
static int cache_dsize = DEFAULT_CACHE_SIZE; // Cache de Datos
static int cache_block_size = DEFAULT_CACHE_BLOCK_SIZE;
static int words_per_block = DEFAULT_CACHE_BLOCK_SIZE / WORD_SIZE;
static int cache_assoc = DEFAULT_CACHE_ASSOC;
static int cache_writeback = DEFAULT_CACHE_WRITEBACK;
static int cache_writealloc = DEFAULT_CACHE_WRITEALLOC;

//Auxiliar Static Variables
static unsigned int set;
static unsigned int offset;
static unsigned int boolaux;
static unsigned int validAux;


/* cache model data structures */
static Pcache icache; //apuntador a i cache
static Pcache dcache; //apuntador a d cache
static cache c1; //Inicializa una estructura de cache llamada c1
static cache c2; //Inicializa una estructura de cache llamada c2
static cache_stat cache_stat_inst; //Inicializa una estructura de estadistica de acceso a instrucciones
static cache_stat cache_stat_data; //Inicializa una estructura de estadistica de acceso a datos
static Pcache_line validPointer;

/************************************************************/
void set_cache_param(param, value)
  int param;
  int value;
{

  switch (param) {
  case CACHE_PARAM_BLOCK_SIZE:
    cache_block_size = value;
    words_per_block = value / WORD_SIZE;
    break;
  case CACHE_PARAM_USIZE:
    cache_split = FALSE;
    cache_usize = value;
    break;
  case CACHE_PARAM_ISIZE:
    cache_split = TRUE;
    cache_isize = value;
    break;
  case CACHE_PARAM_DSIZE:
    cache_split = TRUE;
    cache_dsize = value;
    break;
  case CACHE_PARAM_ASSOC:
    cache_assoc = value;
    break;
  case CACHE_PARAM_WRITEBACK:
    cache_writeback = TRUE;
    break;
  case CACHE_PARAM_WRITETHROUGH:
    cache_writeback = FALSE;
    break;
  case CACHE_PARAM_WRITEALLOC:
    cache_writealloc = TRUE;
    break;
  case CACHE_PARAM_NOWRITEALLOC:
    cache_writealloc = FALSE;
    break;
  default:
    //printf("error set_cache_param: bad parameter value\n");
    exit(-1);
  }

}
/************************************************************/
void init_cache_spec(cache *Pcache, int size)
{
  //printf("init cache Entrada\n");

  Pcache -> size = size;
  Pcache -> associativity =  cache_assoc;
  Pcache -> n_sets = size/(cache_assoc*cache_block_size);
  Pcache -> LRU_head = (Pcache_line *) malloc(sizeof(Pcache_line)*Pcache -> n_sets); //Vector en head Apuntador a la cabeza de las listas doblemente ligadas
  Pcache -> LRU_tail = (Pcache_line *) malloc(sizeof(Pcache_line)*Pcache -> n_sets);
  Pcache -> set_contents = (int *) malloc(sizeof(int)*Pcache -> n_sets);
  set = LOG2(Pcache -> n_sets);
  offset = LOG2(cache_block_size);
  Pcache -> index_mask = (1<<(set+offset))-1;
  Pcache -> index_mask_offset = offset;
  

  //(Pcache -> n_sets)
  for (int i = 0; i < (Pcache -> n_sets); i++){
  //Apuntador a la cabeza de las listas ligadas
  //Definimos espacio para un objeto cache line y lo asignamos al apuntador temp
    Pcache_line temp = malloc(sizeof(cache_line));
    // La cabeza de la lista apunta a la estructura previamente definida
    Pcache -> LRU_head[i] = temp;  
    // Inicializamos los valores del tag
    Pcache -> LRU_head[i]-> tag = -1;  
    Pcache -> LRU_head[i]-> dirty = 0;
    if(cache_assoc==1){
      Pcache->LRU_tail[i]= temp;
      Pcache->LRU_tail[i]-> tag =-1;
      Pcache->LRU_tail[i]-> dirty =0;
      
    }

    for(int j = 0; j < (cache_assoc-1); j++)
    {
      //Definimos espacio para una nueva estructura cache line
      Pcache_line newtemp = malloc(sizeof(cache_line));
      newtemp -> dirty = 0;
      newtemp -> tag = -1;
      if(j==0){
        // Si es la cabeza, sólo apuntamos al siguiente elemento
        Pcache -> LRU_head[i] -> LRU_next = newtemp;
        newtemp -> LRU_prev = temp;
        temp = newtemp;
      }else{
        // En otro caso apuntamos al siguiente elemento y al anterior
          temp -> LRU_next = newtemp;
          newtemp -> LRU_prev = temp;
          temp = newtemp;
      }
      if(j==cache_assoc-2){
          // Si es la cabeza, asignamos el apuntador a Pcache-> LRU_tail
          Pcache -> LRU_tail[i] = newtemp;
      }
    }
  }

    ////printf("init cache Salida\n");
}

/************************************************************/
void init_cache()
{
  /* initialize the cache, and cache statistics data structures */
  if(cache_split==1){
   init_cache_spec(&c1, cache_dsize); //Cache de datos
   init_cache_spec(&c2, cache_isize); //Cache de instrucciones
  }else{
    init_cache_spec(&c1, cache_usize); //Cache Unificado
  }

  cache_stat_inst.accesses=0;
  cache_stat_inst.copies_back=0;
  cache_stat_inst.demand_fetches=0;
  cache_stat_inst.misses=0;
  cache_stat_inst.replacements=0;
  cache_stat_data.accesses=0;
  cache_stat_data.copies_back=0;
  cache_stat_data.demand_fetches=0;
  cache_stat_data.misses=0;
  cache_stat_data.replacements=0;
  
   //Inicializa una estructura de estadistica de acceso a instrucciones
  cache_stat_data;
}
/************************************************************/

/************************************************************/
void perform_access(unsigned addr, unsigned access_type) //Pasamos un adress de trace, access type LOAD STORE, cache
{

  /* handle an access to the cache */
  if (!cache_split){
      perform_access_split(&c1, &c1, access_type, addr); //??
  
  }else
  {
    perform_access_split(&c1, &c2, access_type, addr);
  }
 
}
/************************************************************/

void perform_access_split(cache *PcacheD, cache *PcacheInst, unsigned access_type, unsigned addr){ //Agregar tag o adress
// Llamada desde main, dentro de un while

  unsigned tag = addr>>((set)+(offset)); //tag que voy a buscar
  unsigned index = (addr & PcacheD->index_mask)>>PcacheD->index_mask_offset; //index del renglón
  validAux = 0;

  //printf("tag = %d\n", tag);
  //printf("index = %d\n", index);
  switch (access_type){
        case  TRACE_DATA_LOAD:
          ////printf("TRACE_DATA_LOAD\n");
          ////printf("tag nuestro %d\n", PcacheD-> LRU_head[index] -> tag);
          cache_stat_data.accesses++; 
          boolaux=FALSE; // Definimos boolaux, éste es verdadero si el tag ya está en cache
           
          if(PcacheD->LRU_head[index]-> tag == tag){// Checamos si el tag está en la cabeza de la lista
            ////printf("TAGS iguales en cabeza\n");
            boolaux =TRUE;
          }
          // Si es n-set associative, debemos buscar el tag en la lista
          if(cache_assoc>1){ 
            if(PcacheD->LRU_head[index]-> tag==-1){
              ////printf("Tag en cabeza -1\n");
              validAux = 1;
              validPointer = PcacheD->LRU_head[index];
            }
            int j = 1; 
            Pcache_line pointeraux = PcacheD->LRU_head[index]-> LRU_next;
            while((j < cache_assoc && boolaux!=TRUE) && validAux==0){ // Checamos si el tag está en alguna entrada de la lista
              ////printf("Tag nuestro = %d\n", pointeraux ->tag);
              if(pointeraux->tag==-1){
                validAux = j+1;
                validPointer = pointeraux;
              }
              if(pointeraux -> tag==tag){ //
                boolaux = TRUE;
                //////printf("Tags coinciden \n");
                // Si coincide debemos reacomodar los tags para seguir con la política
                // de eliminación least recently used (LRU)
                //Se recorren los tags a partir de donde se encontró
                // y a la cebeza se asigna el más reciente
                Pcache_line temp = pointeraux;
                int auxdirty = pointeraux ->dirty;
                for(int n = j; n>0;n--){
                  temp -> tag = temp -> LRU_prev -> tag;                  
                  temp -> dirty = temp -> LRU_prev -> dirty;
                  temp = temp -> LRU_prev;
                }
                PcacheD -> LRU_head[index] -> tag = tag;
                PcacheD -> LRU_head[index] -> dirty = auxdirty;                
              }
              pointeraux = pointeraux -> LRU_next;
              j++;
              
            }
          }
          // Si no hay hit
          if(boolaux==FALSE){ 
            ////printf("MiSS\n");
            cache_stat_data.misses++;
            // Actualizamos replacements y fetches
           if(PcacheD->LRU_head[index]->tag!=-1 && cache_assoc==1){
              cache_stat_data.replacements ++;
            }
            if(PcacheD->LRU_tail[index]->tag!=-1 && cache_assoc>1){
              cache_stat_data.replacements ++;
            }
            cache_stat_data.demand_fetches += words_per_block;
            if(cache_assoc==1){ 
              // Si es mapeo directo sólo checamos política de wb
               if (cache_writeback) {
                if(PcacheD->LRU_head[index]-> dirty==1){
                  // Verificamos el dirty bit
                  cache_stat_data.copies_back += words_per_block;
                  PcacheD->LRU_head[index]-> dirty=0;
                }
              } 
              PcacheD -> LRU_head[index] -> tag = tag;
            }else{// EStamos en el caso set associative
              // Si se está en la política write back actualizar según el dirty bit
              if(validAux==0){
                ////printf("Tag colocado previamente\n");
                if (cache_writeback) {
                    if(PcacheD->LRU_tail[index]-> dirty==1){
                      cache_stat_data.copies_back += words_per_block;
                      PcacheD->LRU_tail[index]-> dirty=0;
                    } 
               }
                // Reemplazo y acutalización de la lista de acuerdo a la política LRU
                // auxTemp toma el apuntador para la posición de la cola dentro 
                // de la memoria
                Pcache_line auxTemp =  PcacheD -> LRU_tail[index];
                for(int m=1; m < cache_assoc; m++){
                  // Los tags se van recorriendo hasta llegar a la cabeza
                  //printf("Veces que se pasan los tags%d = \n", m);
                  auxTemp -> tag = auxTemp -> LRU_prev -> tag;
                  auxTemp -> dirty = auxTemp -> LRU_prev -> dirty;
                  auxTemp = auxTemp -> LRU_prev;
                }
                PcacheD -> LRU_head[index] -> tag = tag;
                //printf("NUEVO TAG DE LA CABEZA = %d\n", PcacheD->LRU_head[index]->tag);
                PcacheD -> LRU_head[index] -> dirty = 0;
              
              }else{
                //printf("Lugar de la lista a cambiar =%d\n", validAux);
                if(validAux >1){
                  for(int k = 0; k < (validAux-1); k++){
                    //printf("Veces que se pasan los tags =%d\n",k);
                   validPointer -> tag = validPointer -> LRU_prev-> tag;
                   validPointer -> dirty = validPointer -> LRU_prev->dirty;
                   validPointer = validPointer -> LRU_prev;
                 }
                }
                PcacheD->LRU_head[index]->tag = tag;
                //printf("Nuevo Tag en cabeza=%d\n", PcacheD->LRU_head[index]->tag );
                PcacheD->LRU_head[index]->dirty = 0;
              }
            }
          }
          //printf("---------------------------------------------\n");

         break;

        case TRACE_INST_LOAD:
          cache_stat_inst.accesses++; 
          boolaux=FALSE; // Definimos boolaux, éste es verdadero si el tag ya está en cache
          //printf("TRACE_INST_LOAD\n");
          //printf("tag nuestro %d\n", PcacheInst-> LRU_head[index] -> tag);

          if(PcacheInst->LRU_head[index]-> tag == tag){// Checamos si el tag está en la cabeza de la lista
            //printf("Tags iguales en cabeza\n");
            boolaux =TRUE;
            
          }
          // Si es n-set associative, debemos buscar el tag en la lista
          if(cache_assoc>1){ 
            validAux = 0;
            if(PcacheInst->LRU_head[index]-> tag==-1){
              //printf("Tag en cabeza -1\n");
              validAux = 1;
              validPointer = PcacheInst->LRU_head[index];
            }
            int j = 1; 
            Pcache_line pointeraux = PcacheInst->LRU_head[index]-> LRU_next;
            while((j < cache_assoc && boolaux!=TRUE) && validAux==0){ // Checamos si el tag está en alguna entrada de la lista
              //printf("Tag nuestro = %d\n", pointeraux ->tag);
              if(pointeraux->tag==-1){
                validAux = j+1;
                validPointer = pointeraux;
              }
              if(pointeraux -> tag==tag){ //
                boolaux = TRUE;
                //printf("Tags coinciden \n");
                // Si coincide debemos reacomodar los tags para seguir con la política
                // de eliminación least recently used (LRU)
                //Se recorren los tags a partir de donde se encontró
                // y a la cebeza se asigna el más reciente
                Pcache_line temp = pointeraux;
                int auxdirty = pointeraux ->dirty;
                for(int n = j; n>0;n--){
                  temp -> tag = temp -> LRU_prev -> tag;                  
                  temp -> dirty = temp -> LRU_prev -> dirty;
                  temp = temp -> LRU_prev;
                }
                PcacheInst -> LRU_head[index] -> tag = tag;
                PcacheInst -> LRU_head[index] -> dirty = auxdirty;                
              }
              pointeraux = pointeraux -> LRU_next;
              j++;
              
            }
          }
          // Si no hay hit
          if(boolaux==FALSE){ 
            cache_stat_inst.misses++;
            //printf("MISS\n");
            // Actualizamos replacements y fetches
           if(PcacheInst->LRU_head[index]->tag!=-1 && cache_assoc==1){
              cache_stat_inst.replacements ++;
            }
            if(PcacheInst->LRU_tail[index]->tag!=-1 && cache_assoc>1){
              cache_stat_inst.replacements ++;
            }
            cache_stat_inst.demand_fetches += words_per_block;
            if(cache_assoc==1){ 
              // Si es mapeo directo sólo checamos política de wb
               if (cache_writeback) {
                if(PcacheInst->LRU_head[index]-> dirty==1){
                  // Verificamos el dirty bit
                  cache_stat_inst.copies_back += words_per_block;
                  PcacheInst->LRU_head[index]-> dirty=0;
                }
              } 
              PcacheInst -> LRU_head[index] -> tag = tag;
            }else{// EStamos en el caso set associative
              // Si se está en la política write back actualizar según el dirty bit
              if(validAux==0){
                //printf("Tag colocado previamente\n");
                if (cache_writeback) {
                    if(PcacheInst->LRU_tail[index]-> dirty==1){
                      cache_stat_inst.copies_back += words_per_block;
                      PcacheInst->LRU_tail[index]-> dirty=0;
                    } 
               }
                // Reemplazo y acutalización de la lista de acuerdo a la política LRU
                // auxTemp toma el apuntador para la posición de la cola dentro 
                // de la memoria
                Pcache_line auxTemp =  PcacheInst -> LRU_tail[index];
                for(int m=1; m < cache_assoc; m++){
                  // Los tags se van recorriendo hasta llegar a la cabeza
                  auxTemp -> tag = auxTemp -> LRU_prev -> tag;
                  auxTemp -> dirty = auxTemp -> LRU_prev -> dirty;
                  auxTemp = auxTemp -> LRU_prev;
                  //printf("Veces que se pasan los tags%d = \n", m);

                }
                PcacheInst -> LRU_head[index] -> tag = tag;
                //printf("NUEVO TAG DE LA CABEZA = %d\n", PcacheInst->LRU_head[index]->tag);
                PcacheInst -> LRU_head[index] -> dirty = 0;
              
              }else{
                //printf("Lugar de la lista a cambiar =%d\n", validAux);
                if(validAux >1){
                  for(int k = 0; k <(validAux -1); k++){
                    //printf("Veces que se pasan los tags =%d\n",k);
                   validPointer -> tag = validPointer -> LRU_prev-> tag;
                   validPointer -> dirty = validPointer -> LRU_prev->dirty;
                   validPointer = validPointer -> LRU_prev;
                 }
                }
                PcacheInst->LRU_head[index]->tag = tag;
                //printf("Cambio de tag en la cabeza = %d\n", PcacheInst->LRU_head[index]->tag);
                PcacheInst->LRU_head[index]->dirty = 0;
              }
            }
          }
          //printf("---------------------------------------------\n");
         break;
        case TRACE_DATA_STORE:
          //printf("TRACE_DATA_STORE\n");
          //printf("tag nuestro %d\n", PcacheD-> LRU_head[index] -> tag);

          cache_stat_data.accesses++; // Entra a buscar
          boolaux=FALSE; // Definimos boolaux, éste es verdadero si el tag ya está en cache
           
          if(PcacheD->LRU_head[index]-> tag == tag){// Checamos si el tag está en la cabeza de la lista
            boolaux =TRUE;
            //printf("Tags iguales en cabeza\n");
            if (cache_writeback) {
              PcacheD->LRU_head[index]-> dirty = 1;
            }else{
              cache_stat_data.copies_back ++;
            }
          }
          // Si es n-set associative, debemos buscar el tag en la lista
          if(cache_assoc>1){ 
            validAux = 0;
            if(PcacheD->LRU_head[index]-> tag==-1){
              //printf("Tag en cabeza -1\n");
              validAux = 1;
              validPointer = PcacheD->LRU_head[index];
            }
            int j = 1; 
            Pcache_line pointeraux = PcacheD->LRU_head[index]-> LRU_next;
            while((j < cache_assoc && boolaux!=TRUE) && validAux==0){ // Checamos si el tag está en alguna entrada de la lista
              //printf("Tag nuestro = %d\n", pointeraux ->tag);
              if(pointeraux->tag==-1){
                validAux = j+1;
                validPointer = pointeraux;
              }
              if(pointeraux -> tag==tag){ //
                boolaux = TRUE;
                //printf("Tags coinciden \n");
                // Si coincide debemos reacomodar los tags para seguir con la política
                // de eliminación least recently used (LRU)
                //Se recorren los tags a partir de donde se encontró
                // y a la cebeza se asigna el más reciente
                Pcache_line temp = pointeraux;
                int auxdirty = pointeraux ->dirty;
                for(int n = j; n>0;n--){
                  temp -> tag = temp -> LRU_prev -> tag;                  
                  temp -> dirty = temp -> LRU_prev -> dirty;
                  temp = temp -> LRU_prev;
                }
                PcacheD -> LRU_head[index] -> tag = tag;
                if(cache_writeback){
                  PcacheD -> LRU_head[index] -> dirty = 1;
                }else{
                  cache_stat_data.copies_back ++;
                }
                               
              }
              pointeraux = pointeraux -> LRU_next;
              j++;
            }

        }
        // Si es un miss
        if(boolaux==FALSE){
          //printf("MISS\n");
          //Aumentamos misses
          cache_stat_data.misses ++;

          if (cache_writealloc) {
            cache_stat_data.demand_fetches += words_per_block;
            if(cache_assoc==1){
              // Actualizar replacements
              if(PcacheD->LRU_head[index]->tag!=-1){
                cache_stat_data.replacements ++;
              }
              PcacheD->LRU_head[index]-> tag = tag;
              if (cache_writeback){
                if(PcacheD->LRU_head[index]-> dirty==1){
                  cache_stat_data.copies_back += words_per_block;//ZZ
                  
                }
                PcacheD->LRU_head[index]-> dirty=1;
              }else{
                cache_stat_data.copies_back ++;
              }
            }else{
                if(validAux==0){
                  cache_stat_data.replacements ++;
                  //printf("Tag colocado previamente\n");
                  if (cache_writeback) {
                    if(PcacheD->LRU_tail[index]-> dirty==1){
                      cache_stat_data.copies_back += words_per_block;
                      PcacheD->LRU_tail[index]-> dirty=0;
                    } 
                 }
                  // Reemplazo y acutalización de la lista de acuerdo a la política LRU
                  // auxTemp toma el apuntador para la posición de la cola dentro 
                  // de la memoria
                  Pcache_line auxTemp =  PcacheD -> LRU_tail[index];
                 for(int m=1; m < cache_assoc; m++){
                    // Los tags se van recorriendo hasta llegar a la cabeza
                    //printf("Veces que se pasan los tags%d = \n", m);
                    auxTemp -> tag = auxTemp -> LRU_prev -> tag;
                    auxTemp -> dirty = auxTemp -> LRU_prev -> dirty;
                    auxTemp = auxTemp -> LRU_prev;
                  }
                  PcacheD -> LRU_head[index] -> tag = tag;
                  //printf("NUEVO TAG DE LA CABEZA = %d\n", PcacheD->LRU_head[index]->tag);
                  if(cache_writeback){
                    PcacheD -> LRU_head[index] -> dirty = 1;
                  }            
                }else{
                  //printf("Lugar de la lista a cambiar =%d\n", validAux);
                  if(validAux > 1){
                    for(int k = 0; k < (validAux-1); k++){
                      //printf("Veces que se pasan los tags =%d\n",k);
                      validPointer -> tag = validPointer -> LRU_prev-> tag;
                      validPointer -> dirty = validPointer -> LRU_prev->dirty;
                      validPointer = validPointer -> LRU_prev;
                   }
                  }
                PcacheD->LRU_head[index]->tag = tag;
                //printf("Nuevo Tag en cabeza=%d\n", PcacheD->LRU_head[index]->tag );
                PcacheD->LRU_head[index]->dirty = 0;
                if(cache_writeback){
                  PcacheD->LRU_head[index]->dirty = 1;
                }else{
                  cache_stat_data.copies_back ++;
                }
              }
            }
          }else{
            cache_stat_data.copies_back ++;
          }  
        }  
      //printf("---------------------------------------------\n");     
    break;
  }
}
/*******************************/
void emptyCache(cache *Pcache)
  {
    for (int i = 0; i < (Pcache -> n_sets); i++){
    // 
      if (Pcache->LRU_head[i]->dirty == 1) {
        cache_stat_data.copies_back += words_per_block;
      }
      Pcache->LRU_head[i]->dirty=0;
      Pcache->LRU_head[i]->tag =-1;	
      if(cache_assoc>1){
        Pcache_line temp = Pcache -> LRU_head[i]->LRU_next;
        for(int j = 1; j < cache_assoc; j++){
          if (temp->dirty == 1) {
          cache_stat_data.copies_back += words_per_block;
          }
 	  temp -> dirty=0;
	  temp -> tag=1;
          temp = temp -> LRU_next;
        }
      }
    }
  }
/************************************************************/
void flush()
{
  //print stats in file
  FILE *fptr;
  //char filename=argv[arg_index];
  emptyCache(&c1);
  if(cache_split){
      emptyCache(&c2);
  }
  print_stats();
  fptr=fopen("program.out", "w");
  fprintf(fptr, "\n*** CACHE STATISTICS ***\n");
  fprintf(fptr, " INSTRUCTIONS\n");
  fprintf(fptr, "  accesses:  %d\n", cache_stat_inst.accesses);
  fprintf(fptr, "  misses:    %d\n", cache_stat_inst.misses);
  if (!cache_stat_inst.accesses)
    fprintf(fptr, "  miss rate: 0 (0)\n"); 
  else
    fprintf(fptr, "  miss rate: %2.4f (hit rate %2.4f)\n", 
	 (float)cache_stat_inst.misses / (float)cache_stat_inst.accesses,
	 1.0 - (float)cache_stat_inst.misses / (float)cache_stat_inst.accesses);
  fprintf(fptr, "  replace:   %d\n", cache_stat_inst.replacements);

  fprintf(fptr, " DATA\n");
  fprintf(fptr, "  accesses:  %d\n", cache_stat_data.accesses);
  fprintf(fptr, "  misses:    %d\n", cache_stat_data.misses);
  if (!cache_stat_data.accesses)
    fprintf(fptr, "  miss rate: 0 (0)\n"); 
  else
    fprintf(fptr, "  miss rate: %2.4f (hit rate %2.4f)\n", 
	 (float)cache_stat_data.misses / (float)cache_stat_data.accesses,
	 1.0 - (float)cache_stat_data.misses / (float)cache_stat_data.accesses);
  fprintf(fptr, "  replace:   %d\n", cache_stat_data.replacements);

  fprintf(fptr, " TRAFFIC (in words)\n");
  fprintf(fptr, "  demand fetch:  %d\n", cache_stat_inst.demand_fetches + 
	 cache_stat_data.demand_fetches);
  fprintf(fptr, "  copies back:   %d\n", cache_stat_inst.copies_back +
	 cache_stat_data.copies_back);
 fclose(fptr);

 //Restart stats
  cache_stat_inst.accesses=0;
  cache_stat_inst.copies_back=0;
  cache_stat_inst.demand_fetches=0;
  cache_stat_inst.misses=0;
  cache_stat_inst.replacements=0;
  cache_stat_data.accesses=0;
  cache_stat_data.copies_back=0;
  cache_stat_data.demand_fetches=0;
  cache_stat_data.misses=0;
  cache_stat_data.replacements=0;
}


/************************************************************/

/************************************************************/
void delete(head, tail, item)
  Pcache_line *head, *tail;
  Pcache_line item;
{
  if (item->LRU_prev) { // This notation is used to acces elements of the structure
    item->LRU_prev->LRU_next = item->LRU_next;
  } else {
    /* item at head */
    *head = item->LRU_next;
  }

  if (item->LRU_next) {
    item->LRU_next->LRU_prev = item->LRU_prev;
  } else {
    /* item at tail */
    *tail = item->LRU_prev;
  }
}
/************************************************************/

/************************************************************/
/* inserts at the head of the list */
void insert(head, tail, item)
  Pcache_line *head, *tail;
  Pcache_line item;
{
  item->LRU_next = *head; // This notation is used to acces elements of the structure
  item->LRU_prev = (Pcache_line)NULL;

  if (item->LRU_next)
    item->LRU_next->LRU_prev = item;
  else
    *tail = item;

  *head = item;
}
/************************************************************/

/************************************************************/
void dump_settings()
{
  printf("*** CACHE SETTINGS ***\n");
  if (cache_split) {
    printf("  Split I- D-cache\n");
    printf("  I-cache size: \t%d\n", cache_isize);
    printf("  D-cache size: \t%d\n", cache_dsize);
  } else {
    printf("  Unified I- D-cache\n");
    printf("  Size: \t%d\n", cache_usize);
  }
  printf("  Associativity: \t%d\n", cache_assoc);
  printf("  Block size: \t%d\n", cache_block_size);
  printf("  Write policy: \t%s\n", 
	 cache_writeback ? "WRITE BACK" : "WRITE THROUGH");
  printf("  Allocation policy: \t%s\n",
	 cache_writealloc ? "WRITE ALLOCATE" : "WRITE NO ALLOCATE");
}
/************************************************************/

/************************************************************/
void print_stats()
{
  printf("\n*** CACHE STATISTICS ***\n");

  printf(" INSTRUCTIONS\n");
  printf("  accesses:  %d\n", cache_stat_inst.accesses);
  printf("  misses:    %d\n", cache_stat_inst.misses);
  if (!cache_stat_inst.accesses)
    printf("  miss rate: 0 (0)\n"); 
  else
    printf("  miss rate: %2.4f (hit rate %2.4f)\n", 
	 (float)cache_stat_inst.misses / (float)cache_stat_inst.accesses,
	 1.0 - (float)cache_stat_inst.misses / (float)cache_stat_inst.accesses);
  printf("  replace:   %d\n", cache_stat_inst.replacements);

  printf(" DATA\n");
  printf("  accesses:  %d\n", cache_stat_data.accesses);
  printf("  misses:    %d\n", cache_stat_data.misses);
  if (!cache_stat_data.accesses)
    printf("  miss rate: 0 (0)\n"); 
  else
    printf("  miss rate: %2.4f (hit rate %2.4f)\n", 
	 (float)cache_stat_data.misses / (float)cache_stat_data.accesses,
	 1.0 - (float)cache_stat_data.misses / (float)cache_stat_data.accesses);
  printf("  replace:   %d\n", cache_stat_data.replacements);

  printf(" TRAFFIC (in words)\n");
  printf("  demand fetch:  %d\n", cache_stat_inst.demand_fetches + 
	 cache_stat_data.demand_fetches);
  printf("  copies back:   %d\n", cache_stat_inst.copies_back +
	 cache_stat_data.copies_back);
}
/************************************************************/
