/// @file StateMachine.hpp
///

///
/// @author   DiegoViqueira
/// @version  1.0
/// @date     27/08/2015
///
/// @bug 
/// @warning 

#ifndef ___PROCESSOR_HPP
#define ___PROCESSOR_HPP


#include <ExampleEvents.h>
#include <StateMachine.hpp>

namespace example { 
namespace processor {

   // ---------------------------------------------------
        // CLASS TO PROCESS EVENTS
        // ---------------------------------------------------
         class MainProcessor:  public example::stateMechine::CStateMachine<MainProcessor, example::exampleevents::ExampleEventProcessor >,
                               public base::alloc::enable_shared_from_this<MainProcessor>,
                               public example::exampleevents::ExampleEventProcessor::BaseEvent::IEventReceiver,
                               public example::exampleevents::ExampleEventProcessor
                               
        {
            public:     
            
              MainProcessor()
              {
                    m_pStInitial.reset( new StInitialState(*this));
                    m_pStIntermediate.reset ( new StIntermediateState(*this));
                    m_pStEnd.reset( new StEndState(*this));

                    setState(m_pStInitial.get());
              };

            bool SendEvent( ats::base::alloc::shared_ptr< example::exampleevents::ExampleEventProcessor::BaseEvent > spEvent ) 
            {

                return spEvent->Process(*this);
                
            };


             bool UnexpectedEvent( const std::string& strEventName )
             {
                 std::cout<< "Unexpected Event[" << strEventName << std::endl;
                 return true;
             }
            
            //Visitor Pattern
            bool processEvent(base::alloc::shared_ptr<  example::exampleevents::ExampleEventProcessor::BaseEvent > spEvent)
            {
                        
                        return process( *spEvent );
            }

            bool Process ( exampleevents::InitialEvent& oEvent)     { return  processEvent(oEvent.shared_from_this());};
            bool Process ( exampleevents::IntermediateEvent& oEvent){ return  processEvent(oEvent.shared_from_this());};
            bool Process ( exampleevents::FinalEvent& oEvent)       { return  processEvent(oEvent.shared_from_this());};
         
            
                  
            private:
        
                        class StState : public AState
                        {
                            public:
                            StState( MyContext & context, const char * _stateName ):
                            AState(context,_stateName){}
                            bool DefaultProcess( MyBaseEvent& oEvent )
                            {
                                    std::cout<< "[FSM]" << "Unexpected Event " << oEvent.GetName() << " on state " << GetName()  << std::endl; ;
                                    return true;
                            }  
                        };  
              
                       
                       class StInitialState: public StState
                       {
                            public:
                             StInitialState( MyContext & context):StState(context,"StInitialState"){};
                            
                            
                            bool Process (exampleevents::IntermediateEvent& oEvent)
                            {
                                m_oContext.setState( m_oContext.m_pStIntermediate.get());
                                return true;
                            };
                          
                            bool Process (exampleevents::FinalEvent& oEvent)
                            {
                                m_oContext.setState( m_oContext.m_pStEnd.get());
                                return true;
                            };

                       };

                       
                       class StIntermediateState: public StState
                       {
                            public:
                            StIntermediateState( MyContext & context):StState(context,"StIntermediateState"){};
                            

                            bool Process (exampleevents::InitialEvent& oEvent) 
                            {
                              
                                m_oContext.setState( m_oContext.m_pStEnd.get());
                                return true;
                            };
                          
                            bool Process (exampleevents::FinalEvent& oEvent) 
                            {
                              
                                m_oContext.setState( m_oContext.m_pStEnd.get());
                                return true;
                            };
                          
                       };

                       
                       class StEndState: public StState
                       {
                            public:
                            StEndState( MyContext & context):StState(context,"StEndState"){};
                            
                            bool Process (exampleevents::InitialEvent& oEvent)
                            {
                              
                                m_oContext.setState( m_oContext.m_pStInitial.get());
                                return true;
                            };
                            bool Process (exampleevents::IntermediateEvent& oEvent)
                            {
                              
                                m_oContext.setState( m_oContext.m_pStInitial.get());
                                return true;
                            };
                            
                       };

                //   ----instancias de estados como miembros 
                base::alloc::scoped_ptr<StInitialState>        m_pStInitial;
                base::alloc::scoped_ptr<StIntermediateState>   m_pStIntermediate;
                base::alloc::scoped_ptr<StEndState>            m_pStEnd;

        };



}
}
#endif 

