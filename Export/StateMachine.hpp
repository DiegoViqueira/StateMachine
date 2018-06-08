/// @file StateMachine.hpp
///

///
/// @author   DiegoViqueira
/// @version  1.0
/// @date     27/08/2015
///
/// @bug 
/// @warning 

#ifndef ___STATE_MACHINE_HPP
#define ___STATE_MACHINE_HPP


#include "Event.hpp"

namespace example { 
namespace stateMechine {


//Si se elije que los estados sean smart ptrs:
#define STATE_TRANSITION(state) m_oContext.setState(m_oContext.state.get());
//Si se elije que los estados sean raw ptrs:
#define STATE_TRANSITION_RP(state) m_oContext.setState(m_oContext.state);


//Context tiene que derivar de AEvent<Processor>::Consumer, sinó el static_cast falla
template<typename Context, typename Processor>
class CStateMachine
{
public:
    typedef Context MyContext;
    typedef typename Processor::BaseEvent MyBaseEvent;

    CStateMachine(){}
    class AState : public Processor
    {
    public:
        AState(MyContext& oContext, const char * _stateName)
            :m_oContext(oContext),
             m_strStateName(_stateName){};
        virtual ~AState(){}
        const char* GetName(){return m_strStateName.c_str();};	
    protected:
        
        MyContext&    m_oContext;
    private:
        std::string m_strStateName;
    };
    

    AState* getState()
    {
        return static_cast<AState*>( base::AtomicGet( reinterpret_cast<void*volatile&>( m_pCurrentState ) ) );
    }
    void setState(AState* pState)
    {
        //Loggear el cambio de estado
        base::AtomicSet( reinterpret_cast<void*volatile&>( m_pCurrentState ), pState );
    }

    bool process( typename Processor::BaseEvent& oEvent )
    {
        assert(m_pCurrentState);
        std::cout << "[FSM]" << "Processing Event " << oEvent.GetName() << " on state " << m_pCurrentState->GetName() << std::endl;
        
        if( oEvent.Process(*m_pCurrentState) )
        {
            std::cout << "[FSM]" << "Current state: " << m_pCurrentState->GetName() << std::endl;
            return true;
        }
        else
        {
            std::cout << "[FSM]" << "Error Processing event " << oEvent.GetName() << " Current state: " << m_pCurrentState->GetName() << std::endl;
            return false;
        }
    }
private:
    base::int_types::UInt64 m_nSessionID;
    AState*                 m_pCurrentState;

};




}
}
#endif 

