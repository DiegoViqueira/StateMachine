//============================================================================ 
//                                                                             
//     A T S - Advanced Technology Solutions                                   
//                                                                             
//============================================================================ 

////////////////////////////////////////////////////////////////////////////////
/// \file     Main.cpp
/// \brief    
/// \author  Diego Viqueira
/// \date    creación: 27/08/2015
//______________________________________________________________________________

#include <ats/base/AtsCore.hpp>
#include <ats/base/AtsLog.hpp>
#include <ats/base/timers/Timer.hpp>
#include <AtsStore/AtsStore.hpp>
#include <AtsServ/AtsServ.hpp>

#include <StateMachine.hpp>
#include <ExampleEvents.h>
#include <Event.hpp>
#include <Processor.hpp>



// Main del servicio
int main(const int argc, const char **argv, const char **envp)
{
    // Inicializaciones previas a la entrada a AtsServ
    // ...

	
    // Paso el control a la libreria AtsServ
	    return ats::serv::DoMain(argc, argv, envp);
}





 namespace example {
   namespace framework {

    



     
        // ---------------------------------------------------
        // CLASS TO RECIVE EVENTS
        // ---------------------------------------------------

        class MainReciver:  public serv::Task  ,
                             public base::alloc::enable_shared_from_this<MainReciver>
        {
            public:
                
            
            MainReciver(){   m_spMainProcessor.reset( new example::processor::MainProcessor() ); };

            
            //Implements for Interfase for Task
            const char * name() const { return "MainReciver";};
            bool main()
            {
                while (true)
                {
                    base::alloc::shared_ptr<exampleevents::ExampleEventProcessor::BaseEvent> spEvent;
                    std::string strEntry;
                    std::cout << " Ingrese Tipo de Evento a Enviar " << std::endl;
                    std::cout << " 1 - Initial " << std::endl;
                    std::cout << " 2 - Intermediate " << std::endl;
                    std::cout << " 3 - Final " << std::endl;
                    std::cin >> strEntry;
                    
                
                    if ( strEntry.compare("1") == 0) 
                    {
                                exampleevents::InitialEvent* pEvent(new exampleevents::InitialEvent());
                                spEvent.reset(pEvent);
                    }
                    else if (  strEntry.compare("2") == 0)      
                    {
                                  exampleevents::IntermediateEvent* pEvent(new exampleevents::IntermediateEvent());
                                  spEvent.reset(pEvent);
                    }
                    else if ( strEntry.compare("3") == 0)      
                    {
                                  exampleevents::FinalEvent* pEvent(new exampleevents::FinalEvent());
                                  spEvent.reset(pEvent);
                    }
                    else
                    {
                                  exampleevents::FinalEvent* pEvent(new exampleevents::FinalEvent());
                                  spEvent.reset(pEvent);
                    }


                  
                    m_spMainProcessor->SendEvent(spEvent);

                  


                }
            };
            ats::base::t_milisec stop(){ return 1000;};

        private: 

            ats::base::alloc::shared_ptr< example::processor::MainProcessor > m_spMainProcessor;

        };

 };//
};// End namespace



//Namespaces
namespace ats { 
namespace serv {

using namespace std;


// -----------------------------------------------------------------------------
// ats::serv::SetupUserTasks: aca se le dice a la libreria AtsServ cuales son
//                            mis tareas (threads) y en que order ejecutarlas
// -----------------------------------------------------------------------------
void SetupUserTasks()
{
    

       ///SCP Interface:
       ats::base::alloc::shared_ptr< example::framework::MainReciver > spMainReciver( new example::framework::MainReciver() );
       AddUserTask( spMainReciver );
}

}}  // ats::serv namespace



//Namespaces