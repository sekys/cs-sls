/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/
/* 
	- Anty flood plugin nesmie byt na servery inak blokuje chat, uzivatelia nemozu pisat
	- Vela funkcii je offline, lebo gametime rozdiel je 0
	- Najme clientske funkcie stale pracuju ako addToFullPack alebo asi messages
	- IDE -....show hud pravdepodobne tiez nepojde ako ma, pretoze je tam casovac
	- get_gametime sa zastavi pri pauze
*/

new TaskTime;
new TaskRunnig = false;
new TaskEventHandler;

stock TaskStart() {
	// Zapni Task
	if(TaskRunnig) return;
	TaskRunnig = true;
	TaskEventHandler = register_forward(FM_AddToFullPack, "addToFullPack", 1);
}
public addToFullPack(	const es,const e,const ent, const host, 
						const flags,const player,const pSet 
) {
	// Volane kazdu 1.0
	if(TaskRunnig) { // Len ak bezi, moze sa dalej rekurzivne volat, preto je to lepsie
		if((get_systime() - TaskTime) >= 1) {
			// Volana funkcia
			sls_PauseTask();
			TaskTime = get_systime();
		}
	}
}
stock TaskDestroy() {
	if(!TaskRunnig) return;
	TaskRunnig = false;
	unregister_forward(FM_StartFrame, TaskEventHandler, 1); // toto nieje spolahlive
}
